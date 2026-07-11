import Foundation
import Domain

/// An SSH endpoint to health-check (management access is expected behind Tailscale).
public struct SSHTarget: Sendable, Equatable {
    public let host: String
    public let port: Int
    public let username: String
    /// Keychain key of the identity used to authenticate, if any.
    public let identityKey: String?

    public init(host: String, port: Int = 22, username: String, identityKey: String? = nil) {
        self.host = host
        self.port = port
        self.username = username
        self.identityKey = identityKey
    }
}

/// Endpoints for the Home probes. Everything is optional: nothing is invented —
/// an unconfigured target simply resolves to `.unknown`. The composition root
/// supplies real values (typically private Tailscale addresses).
public struct HomeProbeConfiguration: Sendable {
    public var vps: SSHTarget?
    public var openClaw: URL?
    public var ollama: URL?

    public init(vps: SSHTarget? = nil, openClaw: URL? = nil, ollama: URL? = nil) {
        self.vps = vps
        self.openClaw = openClaw
        self.ollama = ollama
    }

    public static let unconfigured = HomeProbeConfiguration()
}

/// Probes an HTTP(S) health endpoint.
public protocol HTTPHealthProbe: Sendable {
    func probe(_ url: URL) async -> HealthState
}

/// Probes an SSH endpoint (real implementation added with the SSH client).
public protocol SSHHealthProbe: Sendable {
    func probe(_ target: SSHTarget) async -> HealthState
}

/// Placeholder SSH probe used until an SSH client is wired. Reports `.unknown`
/// rather than guessing — it never fabricates a healthy result.
public struct UnavailableSSHProbe: SSHHealthProbe {
    public init() {}
    public func probe(_ target: SSHTarget) async -> HealthState { .unknown }
}
