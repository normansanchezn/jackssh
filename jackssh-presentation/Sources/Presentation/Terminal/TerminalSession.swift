import Foundation
import Observation
import Domain
import SwiftTerm

/// Owns the lifecycle of one interactive terminal: opening the PTY channel,
/// pumping remote bytes into the SwiftTerm emulator, forwarding keystrokes,
/// and transparently reconnecting when the connection drops.
///
/// The UI layer never talks to the channel directly — it only observes `phase`
/// and hands the session its `TerminalView` to feed. This keeps the "UI never
/// executes commands" boundary intact.
@MainActor
@Observable
public final class TerminalSession {
    public private(set) var phase: TerminalConnectionPhase = .connecting
    public private(set) var remoteTitle: String?

    private let host: Domain.Host
    private let openTerminal: OpenTerminal
    private let activateSession: ActivateConnectionSession
    private let endSession: EndConnectionSession
    private let startupDirectory: String?

    @ObservationIgnored private weak var terminalView: SwiftTerm.TerminalView?
    @ObservationIgnored private var channel: TerminalChannel?
    @ObservationIgnored private var lifecycleTask: Task<Void, Never>?
    @ObservationIgnored private var started = false
    @ObservationIgnored private var userClosed = false
    @ObservationIgnored private var startupCommandsSent = false
    @ObservationIgnored private var reconnectAttempt = 0

    private let maxReconnectAttempts = 5

    public init(
        host: Domain.Host,
        openTerminal: OpenTerminal,
        activateSession: ActivateConnectionSession,
        endSession: EndConnectionSession,
        startupDirectory: String? = nil
    ) {
        self.host = host
        self.openTerminal = openTerminal
        self.activateSession = activateSession
        self.endSession = endSession
        self.startupDirectory = startupDirectory
    }

    /// Called by the representable once the SwiftTerm view exists. Kicks off the
    /// first connection on the initial call.
    func attach(_ view: SwiftTerm.TerminalView) {
        terminalView = view
        guard !started else { return }
        started = true
        beginConnectLoop()
    }

    /// Forward raw keystroke bytes from the emulator to the remote PTY stdin.
    func sendToRemote(_ data: ArraySlice<UInt8>) {
        let bytes = Array(data)
        Task { await channel?.send(bytes) }
    }

    public func sendBytes(_ bytes: [UInt8]) {
        Task { await channel?.send(bytes) }
    }

    public func sendText(_ text: String) {
        sendBytes(Array(text.utf8))
    }

    /// Propagate a window-size change to the remote so full-screen apps reflow.
    func resizeRemote(cols: Int, rows: Int) {
        Task { await channel?.resize(cols: cols, rows: rows) }
    }

    func setTitle(_ title: String) {
        remoteTitle = title
    }

    /// User-initiated manual reconnect (from the status pill).
    public func reconnectNow() {
        guard started else { return }
        userClosed = false
        reconnectAttempt = 0
        beginConnectLoop()
    }

    /// Tear the session down for good (view disappeared).
    public func stop() {
        userClosed = true
        lifecycleTask?.cancel()
        let ch = channel
        channel = nil
        Task {
            await endSession(for: host.id)
            await ch?.close()
        }
    }

    // MARK: - Connection loop

    private func beginConnectLoop() {
        lifecycleTask?.cancel()
        lifecycleTask = Task { [weak self] in
            await self?.runConnectLoop()
        }
    }

    private func runConnectLoop() async {
        while !userClosed && !Task.isCancelled {
            let (cols, rows) = currentSize()
            phase = reconnectAttempt == 0 ? .connecting : .reconnecting(attempt: reconnectAttempt)

            do {
                let ch = try await openTerminal(to: host, cols: cols, rows: rows)
                guard !userClosed else { await ch.close(); return }
                channel = ch
                reconnectAttempt = 0
                await activateSession(
                    ConnectedHostSession(
                        hostID: host.id,
                        hostname: host.hostname,
                        username: host.username,
                        port: host.port
                    )
                )
                phase = .connected
                await sendStartupCommandsIfNeeded(on: ch)

                // Pump remote bytes until the stream ends (connection closed).
                for await bytes in ch.output {
                    terminalView?.feed(byteArray: ArraySlice(bytes))
                }
            } catch {
                phase = .failed(Self.message(for: error))
            }

            channel = nil
            if userClosed || Task.isCancelled { return }

            // Connection ended — attempt auto-reconnect with linear backoff.
            reconnectAttempt += 1
            if reconnectAttempt > maxReconnectAttempts {
                phase = .disconnected(reason: "Connection lost")
                await endSession(for: host.id)
                return
            }
            phase = .reconnecting(attempt: reconnectAttempt)
            feedLocalNotice("\r\n[reconnecting — attempt \(reconnectAttempt)/\(maxReconnectAttempts)]\r\n")
            try? await Task.sleep(nanoseconds: UInt64(reconnectAttempt) * 1_000_000_000)
        }
    }

    // MARK: - Helpers

    private func currentSize() -> (cols: Int, rows: Int) {
        guard let terminal = terminalView?.getTerminal() else { return (80, 24) }
        let dims = terminal.getDims()
        let cols = dims.cols > 0 ? dims.cols : 80
        let rows = dims.rows > 0 ? dims.rows : 24
        return (cols, rows)
    }

    /// Write a local status line into the emulator (not sent to the remote).
    private func feedLocalNotice(_ text: String) {
        terminalView?.feed(text: text)
    }

    private func sendStartupCommandsIfNeeded(on channel: TerminalChannel) async {
        guard !startupCommandsSent else { return }

        startupCommandsSent = true
        var commands = [Self.promptCommand]
        if let startupDirectory, !startupDirectory.isEmpty {
            commands.append("cd \(Self.shellQuoted(startupDirectory))")
        }
        await channel.send(Array("\(commands.joined(separator: "\n"))\n".utf8))
    }

    private static func shellQuoted(_ value: String) -> String {
        "'\(value.replacingOccurrences(of: "'", with: "'\\''"))'"
    }

    private static let promptCommand = """
if [ -n "$BASH_VERSION" ]; then export PS1='\\[\\033[38;5;75m\\]\\u\\[\\033[0m\\]\\[\\033[38;5;244m\\]@\\[\\033[0m\\]\\[\\033[38;5;114m\\]\\h\\[\\033[0m\\] \\[\\033[38;5;179m\\]\\w\\[\\033[0m\\]\\n\\[\\033[38;5;75m\\]➜\\[\\033[0m\\] '; elif [ -n "$ZSH_VERSION" ]; then export PROMPT='%F{75}%n%f%F{244}@%f%F{114}%m%f %F{179}%~%f
%F{75}➜%f '; else export PS1='\\033[38;5;75m$(whoami)\\033[0m\\033[38;5;244m@\\033[0m\\033[38;5;114m$(hostname -s 2>/dev/null || hostname)\\033[0m \\033[38;5;179m$PWD\\033[0m
\\033[38;5;75m➜\\033[0m '; fi
"""

    private static func message(for error: Error) -> String {
        if let domain = error as? DomainError {
            switch domain {
            case .unauthorized: return "Authentication failed"
            case .notFound: return "Credentials not found"
            case .timeout: return "Connection timed out"
            case .offline, .unreachable: return "Host unreachable"
            default: return "Connection failed"
            }
        }
        return error.localizedDescription
    }
}
