import Foundation

/// Opens a local SSH tunnel from this device to a remote service behind a host.
public struct OpenPortForward: Sendable {
    private let forwarding: PortForwarding

    public init(forwarding: PortForwarding) {
        self.forwarding = forwarding
    }

    public func callAsFunction(
        to host: Host,
        target: PortForwardTarget,
        scheme: String,
        basePath: String
    ) async throws -> PortForwardSession {
        try await forwarding.startLocalForward(
            to: host,
            target: target,
            scheme: scheme,
            basePath: basePath
        )
    }
}
