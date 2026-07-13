import Foundation
@preconcurrency import Citadel
import Domain
import NIO
import NIOSSH

/// Local SSH port forwarding backed by Citadel direct-tcpip channels.
///
/// This is the app-scoped equivalent of:
/// `ssh -L 127.0.0.1:<local-port>:<target-host>:<target-port> user@vps`.
/// The returned local endpoint is intended for in-app consumers such as WKWebView.
@available(macOS 15.0, *)
public struct CitadelPortForwarding: PortForwarding {
    private let secretStore: SecretStore
    private let connectTimeout: TimeInterval

    public init(secretStore: SecretStore, connectTimeout: TimeInterval = 15) {
        self.secretStore = secretStore
        self.connectTimeout = connectTimeout
    }

    public func startLocalForward(
        to host: Domain.Host,
        target: PortForwardTarget,
        scheme: String,
        basePath: String
    ) async throws -> PortForwardSession {
        let auth = try await authentication(for: host)
        let client = try await SSHClient.connect(
            host: host.hostname,
            port: host.port,
            authenticationMethod: auth,
            hostKeyValidator: .acceptAnything(), // TODO: TOFU host-key store
            reconnect: .never,
            connectTimeout: .seconds(Int64(connectTimeout))
        )

        do {
            return try await CitadelLocalPortForwardSession.start(
                client: client,
                target: target,
                scheme: scheme,
                basePath: basePath
            )
        } catch {
            try? await client.close()
            throw error
        }
    }

    private func authentication(for host: Domain.Host) async throws -> SSHAuthenticationMethod {
        switch host.authenticationMethod {
        case .password:
            let key = SecretKey.password(hostID: host.id)
            guard let data = try await secretStore.secret(for: key),
                  let password = String(data: data, encoding: .utf8) else {
                throw DomainError.notFound
            }
            return .passwordBased(username: host.username, password: password)

        case .publicKey:
            throw DomainError.unknown
        }
    }
}

@available(macOS 15.0, *)
private final class CitadelLocalPortForwardSession: PortForwardSession, @unchecked Sendable {
    nonisolated(unsafe) private let client: SSHClient
    private let serverChannel: Channel
    private let group: MultiThreadedEventLoopGroup

    let endpoint: PortForwardEndpoint

    private init(
        client: SSHClient,
        serverChannel: Channel,
        group: MultiThreadedEventLoopGroup,
        endpoint: PortForwardEndpoint
    ) {
        self.client = client
        self.serverChannel = serverChannel
        self.group = group
        self.endpoint = endpoint
    }

    static func start(
        client: SSHClient,
        target: PortForwardTarget,
        scheme: String,
        basePath: String
    ) async throws -> CitadelLocalPortForwardSession {
        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)

        do {
            let server = try await bindLocalServer(group: group, client: client, target: target)

            guard let localPort = server.localAddress?.port else {
                try? await server.close()
                try? await group.shutdownGracefully()
                throw DomainError.unknown
            }

            return CitadelLocalPortForwardSession(
                client: client,
                serverChannel: server,
                group: group,
                endpoint: PortForwardEndpoint(
                    localHost: "127.0.0.1",
                    localPort: localPort,
                    remoteHost: target.host,
                    remotePort: target.port,
                    scheme: scheme,
                    basePath: basePath
                )
            )
        } catch {
            try? await group.shutdownGracefully()
            throw error
        }
    }

    private static func bindLocalServer(
        group: MultiThreadedEventLoopGroup,
        client: SSHClient,
        target: PortForwardTarget
    ) async throws -> Channel {
        if let preferredLocalPort = target.preferredLocalPort {
            do {
                return try await makeServerBootstrap(group: group, client: client, target: target)
                    .bind(host: "127.0.0.1", port: preferredLocalPort)
                    .get()
            } catch {
                // Keep the feature usable if the stable local port is already taken.
            }
        }

        return try await makeServerBootstrap(group: group, client: client, target: target)
            .bind(host: "127.0.0.1", port: 0)
            .get()
    }

    private static func makeServerBootstrap(
        group: MultiThreadedEventLoopGroup,
        client: SSHClient,
        target: PortForwardTarget
    ) -> ServerBootstrap {
        let clientBox = UnsafeSendableBox(value: client)

        return ServerBootstrap(group: group)
            .serverChannelOption(ChannelOptions.backlog, value: 64)
            .serverChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
            .childChannelInitializer { localChannel in
                let promise = localChannel.eventLoop.makePromise(of: Void.self)
                Task {
                    do {
                        try await Self.bridge(localChannel: localChannel, client: clientBox.value, target: target)
                        promise.succeed(())
                    } catch {
                        promise.fail(error)
                        try? await localChannel.close()
                    }
                }
                return promise.futureResult
            }
            .childChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
    }

    func stop() async {
        try? await serverChannel.close()
        try? await client.close()
        try? await group.shutdownGracefully()
    }

    private static func bridge(
        localChannel: Channel,
        client: SSHClient,
        target: PortForwardTarget
    ) async throws {
        let originatorAddress: SocketAddress
        if let remoteAddress = localChannel.remoteAddress {
            originatorAddress = remoteAddress
        } else {
            originatorAddress = try SocketAddress(ipAddress: "127.0.0.1", port: 0)
        }

        let remoteChannel = try await client.createDirectTCPIPChannel(
            using: SSHChannelType.DirectTCPIP(
                targetHost: target.host,
                targetPort: target.port,
                originatorAddress: originatorAddress
            )
        ) { remoteChannel in
            remoteChannel.pipeline.addHandler(PortForwardPipeHandler(peer: localChannel))
        }

        try await localChannel.pipeline.addHandler(PortForwardPipeHandler(peer: remoteChannel)).get()
    }
}

private struct UnsafeSendableBox<T>: @unchecked Sendable {
    let value: T
}

private final class PortForwardPipeHandler: ChannelInboundHandler, @unchecked Sendable {
    typealias InboundIn = ByteBuffer
    typealias OutboundOut = ByteBuffer

    private let peer: Channel

    init(peer: Channel) {
        self.peer = peer
    }

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let buffer = unwrapInboundIn(data)
        peer.writeAndFlush(buffer, promise: nil)
    }

    func channelInactive(context: ChannelHandlerContext) {
        peer.close(promise: nil)
        context.fireChannelInactive()
    }

    func errorCaught(context: ChannelHandlerContext, error: Error) {
        peer.close(promise: nil)
        context.close(promise: nil)
    }
}
