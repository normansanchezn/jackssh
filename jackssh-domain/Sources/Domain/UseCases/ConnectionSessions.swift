import Foundation

/// Records a verified active SSH session for presentation and navigation.
public struct ActivateConnectionSession: Sendable {
    private let store: ConnectionSessionStore

    public init(store: ConnectionSessionStore) {
        self.store = store
    }

    public func callAsFunction(_ session: ConnectedHostSession) async {
        await store.activate(session)
    }
}

/// Retrieves the latest session that is still active in this app process.
public struct LoadActiveConnectionSession: Sendable {
    private let store: ConnectionSessionStore

    public init(store: ConnectionSessionStore) {
        self.store = store
    }

    public func callAsFunction() async -> ConnectedHostSession? {
        await store.mostRecentActiveSession()
    }

    public func callAsFunction(for hostID: UUID) async -> ConnectedHostSession? {
        await store.activeSession(for: hostID)
    }
}

/// Ends the tracked session for a host after a user disconnects or its channel closes.
public struct EndConnectionSession: Sendable {
    private let store: ConnectionSessionStore

    public init(store: ConnectionSessionStore) {
        self.store = store
    }

    public func callAsFunction(for hostID: UUID) async {
        await store.deactivate(hostID: hostID)
    }
}
