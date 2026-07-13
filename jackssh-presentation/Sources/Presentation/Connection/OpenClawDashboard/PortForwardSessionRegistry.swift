import Domain
import Foundation

@MainActor
public final class PortForwardSessionRegistry {
    private var sessions: [UUID: RegisteredPortForwardSession] = [:]

    public init() {}

    public func session(for hostID: UUID) -> RegisteredPortForwardSession? {
        sessions[hostID]
    }

    public func register(_ session: RegisteredPortForwardSession, for hostID: UUID) {
        sessions[hostID] = session
    }

    public func removeSession(for hostID: UUID) -> RegisteredPortForwardSession? {
        sessions.removeValue(forKey: hostID)
    }
}

public struct RegisteredPortForwardSession {
    public let host: Domain.Host
    public let session: PortForwardSession
    public let endpoint: PortForwardEndpoint
    public let dashboardURL: URL
    public let tunnelDescription: String
    public let authToken: String?

    public init(
        host: Domain.Host,
        session: PortForwardSession,
        endpoint: PortForwardEndpoint,
        dashboardURL: URL,
        tunnelDescription: String,
        authToken: String?
    ) {
        self.host = host
        self.session = session
        self.endpoint = endpoint
        self.dashboardURL = dashboardURL
        self.tunnelDescription = tunnelDescription
        self.authToken = authToken
    }
}
