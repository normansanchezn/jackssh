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

/// Resolves a short-lived dashboard token from the remote host.
public protocol OpenClawAuthenticating: Sendable {
    func token(for host: Host, configuration: OpenClawConfiguration) async throws -> String?
}

public struct ResolveOpenClawAuthToken: Sendable {
    private let authenticator: OpenClawAuthenticating

    public init(authenticator: OpenClawAuthenticating) {
        self.authenticator = authenticator
    }

    public func callAsFunction(
        for host: Host,
        configuration: OpenClawConfiguration
    ) async throws -> String? {
        try await authenticator.token(for: host, configuration: configuration)
    }
}
