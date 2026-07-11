import Foundation
import Citadel
import Domain

/// Real SSH health probe built on Citadel (swift-nio-ssh).
///
/// Security posture:
/// - Host-key verification is mandatory. Callers supply a `SSHHostKeyValidator`;
///   this probe never uses `.acceptAnything()`. An unknown/changed key fails the
///   handshake, surfacing as `.degraded` (reachable but untrusted) — never silently accepted.
/// - Credentials are supplied per target by the injected `sessionProvider`
///   (typically reading a private key from the Keychain). When a target is not
///   fully configured (no credentials or no trusted host key), the provider
///   returns `nil` and the probe reports `.unknown` WITHOUT connecting.
/// - Nothing sensitive is logged.
public struct CitadelSSHHealthProbe: SSHHealthProbe {
    /// Everything needed to attempt one authenticated, host-key-verified connection.
    public struct Session {
        public let authentication: SSHAuthenticationMethod
        public let hostKeyValidator: SSHHostKeyValidator

        public init(authentication: SSHAuthenticationMethod, hostKeyValidator: SSHHostKeyValidator) {
            self.authentication = authentication
            self.hostKeyValidator = hostKeyValidator
        }
    }

    private let connectTimeout: TimeInterval
    private let sessionProvider: @Sendable (SSHTarget) async -> Session?

    /// - Parameter sessionProvider: Resolves auth + trusted host key for a target,
    ///   or `nil` to refuse the connection (missing credentials / unknown host).
    public init(
        connectTimeout: TimeInterval = 8,
        sessionProvider: @escaping @Sendable (SSHTarget) async -> Session?
    ) {
        self.connectTimeout = connectTimeout
        self.sessionProvider = sessionProvider
    }

    public func probe(_ target: SSHTarget) async -> HealthState {
        // Refuse to connect when the target isn't fully, securely configured.
        guard let session = await sessionProvider(target) else { return .unknown }

        do {
            let client = try await SSHClient.connect(
                host: target.host,
                port: target.port,
                authenticationMethod: session.authentication,
                hostKeyValidator: session.hostKeyValidator,
                reconnect: .never,
                connectTimeout: .seconds(Int64(connectTimeout))
            )
            try? await client.close()
            return .online
        } catch {
            // Network-level failure → offline. Handshake/auth/host-key failure →
            // reachable but not healthy/trusted → degraded.
            switch ErrorMapper.map(error) {
            case .offline, .unreachable, .timeout: return .offline
            default: return .degraded
            }
        }
    }
}
