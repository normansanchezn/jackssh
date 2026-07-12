import Foundation
import Domain

/// Process-lifetime source of truth for verified SSH sessions.
///
/// Metadata is kept only in memory, so a terminated app never claims that an
/// old transport is still connected. Returning from background preserves the
/// entry while the process and its channel remain alive.
public actor InMemoryConnectionSessionStore: ConnectionSessionStore {
    private var sessions: [UUID: ConnectedHostSession] = [:]

    public init() {}

    public func activeSession(for hostID: UUID) async -> ConnectedHostSession? {
        sessions[hostID]
    }

    public func mostRecentActiveSession() async -> ConnectedHostSession? {
        sessions.values.max { $0.connectedAt < $1.connectedAt }
    }

    public func activate(_ session: ConnectedHostSession) async {
        sessions[session.hostID] = session
    }

    public func deactivate(hostID: UUID) async {
        sessions.removeValue(forKey: hostID)
    }
}
