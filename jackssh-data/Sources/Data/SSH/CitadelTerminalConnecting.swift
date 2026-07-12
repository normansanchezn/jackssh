import Foundation
import Citadel
import NIOCore
import NIOSSH
import Domain

/// Real interactive-terminal transport built on Citadel (swift-nio-ssh).
///
/// Opens an authenticated SSH connection and requests a PTY, then bridges the
/// PTY's byte streams into the Domain `TerminalChannel` contract. Unlike the
/// old command-executor stub, this streams stdout/stderr live and forwards
/// keystrokes verbatim — the remote shell owns the prompt and line editing.
///
/// Security note: host-key verification currently uses `.acceptAnything()`.
/// This is a known Phase-1 gap — a trust-on-first-use (TOFU) store keyed by
/// host should replace it before shipping. The validator is the single point
/// to harden.
@available(macOS 15.0, *)
public struct CitadelTerminalConnecting: TerminalConnecting {
    private let secretStore: SecretStore
    private let connectTimeout: TimeInterval

    public init(secretStore: SecretStore, connectTimeout: TimeInterval = 15) {
        self.secretStore = secretStore
        self.connectTimeout = connectTimeout
    }

    public func connect(to host: Domain.Host, cols: Int, rows: Int) async throws -> TerminalChannel {
        let auth = try await authentication(for: host)

        let client = try await SSHClient.connect(
            host: host.hostname,
            port: host.port,
            authenticationMethod: auth,
            hostKeyValidator: .acceptAnything(), // TODO: TOFU host-key store
            reconnect: .never,
            connectTimeout: .seconds(Int64(connectTimeout))
        )

        let channel = CitadelTerminalChannel(client: client, cols: cols, rows: rows)
        await channel.start()
        return channel
    }

    private func authentication(for host: Domain.Host) async throws -> SSHAuthenticationMethod {
        switch host.authenticationMethod {
        case .password:
            let key = "host:\(host.id):auth"
            guard let data = try await secretStore.secret(for: key),
                  let password = String(data: data, encoding: .utf8) else {
                throw DomainError.notFound
            }
            return .passwordBased(username: host.username, password: password)

        case .publicKey:
            // Key-based auth requires parsing the stored PEM into the concrete
            // key type (ed25519/RSA/p256…). Not wired in Phase 1 — password auth
            // covers the common VPS root login. Surface a clear error instead of
            // silently failing the handshake.
            throw DomainError.unknown
        }
    }
}

/// A Sendable envelope for outbound PTY operations (stdin bytes / resize).
private enum TerminalOutbound: Sendable {
    case bytes([UInt8])
    case resize(cols: Int, rows: Int)
}

/// Trust-me wrapper to carry Citadel's non-Sendable PTY handles across the
/// structured-concurrency boundary inside a single, serial task scope. Safe
/// because each handle is only ever touched from one child task.
private struct UnsafeSendableBox<T>: @unchecked Sendable {
    let value: T
}

/// Bridges Citadel's closure-scoped `withPTY` API into a long-lived
/// `TerminalChannel`. The PTY lives in one task; inbound bytes are yielded to
/// `output`, and outbound keystrokes/resizes flow through a Sendable stream so
/// the non-Sendable stdin writer never escapes the PTY task.
@available(macOS 15.0, *)
final class CitadelTerminalChannel: TerminalChannel, @unchecked Sendable {
    nonisolated(unsafe) private let client: SSHClient
    private let cols: Int
    private let rows: Int

    let output: AsyncStream<[UInt8]>
    private let outputContinuation: AsyncStream<[UInt8]>.Continuation
    private let outbound: AsyncStream<TerminalOutbound>
    private let outboundContinuation: AsyncStream<TerminalOutbound>.Continuation
    private var ptyTask: Task<Void, Never>?

    init(client: SSHClient, cols: Int, rows: Int) {
        self.client = client
        self.cols = cols
        self.rows = rows
        (output, outputContinuation) = AsyncStream.makeStream(bufferingPolicy: .unbounded)
        (outbound, outboundContinuation) = AsyncStream.makeStream(bufferingPolicy: .unbounded)
    }

    func start() {
        let request = SSHChannelRequestEvent.PseudoTerminalRequest(
            wantReply: true,
            term: "xterm-256color",
            terminalCharacterWidth: cols,
            terminalRowHeight: rows,
            terminalPixelWidth: 0,
            terminalPixelHeight: 0,
            terminalModes: SSHTerminalModes([:])
        )

        let client = UnsafeSendableBox(value: self.client)
        let outputContinuation = self.outputContinuation
        let outbound = self.outbound

        ptyTask = Task {
            do {
                try await client.value.withPTY(request) { inbound, writer in
                    let inbox = UnsafeSendableBox(value: inbound)
                    let writerBox = UnsafeSendableBox(value: writer)

                    try await withThrowingTaskGroup(of: Void.self) { group in
                        // Pump: remote PTY → output stream.
                        group.addTask {
                            for try await event in inbox.value {
                                switch event {
                                case .stdout(let buffer), .stderr(let buffer):
                                    outputContinuation.yield(Array(buffer.readableBytesView))
                                }
                            }
                        }
                        // Drain: outbound stream → remote PTY stdin.
                        group.addTask {
                            let writer = writerBox.value
                            for await message in outbound {
                                switch message {
                                case .bytes(let bytes):
                                    try? await writer.write(ByteBuffer(bytes: bytes))
                                case .resize(let cols, let rows):
                                    try? await writer.changeSize(cols: cols, rows: rows, pixelWidth: 0, pixelHeight: 0)
                                }
                            }
                        }
                        // When the remote closes (pump returns), tear down.
                        try await group.next()
                        group.cancelAll()
                    }
                }
            } catch {
                // Handshake dropped / PTY closed — surface as stream end so the
                // session can move to `.reconnecting`.
            }
            outputContinuation.finish()
        }
    }

    func send(_ bytes: [UInt8]) async {
        outboundContinuation.yield(.bytes(bytes))
    }

    func resize(cols: Int, rows: Int) async {
        outboundContinuation.yield(.resize(cols: cols, rows: rows))
    }

    func close() async {
        outboundContinuation.finish()
        ptyTask?.cancel()
        outputContinuation.finish()
        let client = UnsafeSendableBox(value: self.client)
        try? await client.value.close()
    }
}
