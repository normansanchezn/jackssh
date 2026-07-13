import Foundation

/// Target reachable from the remote SSH server.
public struct PortForwardTarget: Equatable, Sendable {
    public let host: String
    public let port: Int
    public let preferredLocalPort: Int?

    public init(host: String, port: Int, preferredLocalPort: Int? = nil) {
        self.host = host
        self.port = port
        self.preferredLocalPort = preferredLocalPort
    }
}

/// Local endpoint exposed on the user's device for a remote service.
public struct PortForwardEndpoint: Equatable, Sendable {
    public let localHost: String
    public let localPort: Int
    public let remoteHost: String
    public let remotePort: Int
    public let scheme: String
    public let basePath: String

    public init(
        localHost: String,
        localPort: Int,
        remoteHost: String,
        remotePort: Int,
        scheme: String,
        basePath: String
    ) {
        self.localHost = localHost
        self.localPort = localPort
        self.remoteHost = remoteHost
        self.remotePort = remotePort
        self.scheme = scheme
        self.basePath = basePath
    }

    public var localURL: URL? {
        URL(string: "\(scheme)://\(localHost):\(localPort)\(basePath)")
    }
}

/// A running local SSH tunnel. Call `stop()` when the consuming screen closes.
public protocol PortForwardSession: Sendable {
    var endpoint: PortForwardEndpoint { get }
    func stop() async
}

/// Starts local SSH port forwards, equivalent to `ssh -L`.
public protocol PortForwarding: Sendable {
    func startLocalForward(
        to host: Host,
        target: PortForwardTarget,
        scheme: String,
        basePath: String
    ) async throws -> PortForwardSession
}
