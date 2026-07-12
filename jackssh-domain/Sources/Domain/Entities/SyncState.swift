import Foundation

/// Local change pending sync to remote.
public struct PendingSync: Equatable, Sendable {
    public enum Operation: String, Equatable, Sendable {
        case create, update, delete
    }

    public let id: UUID
    public let entityType: String // "host", "credential", etc.
    public let entityID: UUID
    public let operation: Operation
    public let timestamp: Date
    public let payload: String? // JSON data

    public init(
        id: UUID = UUID(),
        entityType: String,
        entityID: UUID,
        operation: Operation,
        timestamp: Date = Date(),
        payload: String? = nil
    ) {
        self.id = id
        self.entityType = entityType
        self.entityID = entityID
        self.operation = operation
        self.timestamp = timestamp
        self.payload = payload
    }
}

/// Sync status for the app.
public struct SyncStatus: Equatable, Sendable {
    public let isOnline: Bool
    public let pendingCount: Int
    public let lastSyncTime: Date?
    public let isSyncing: Bool

    public init(
        isOnline: Bool,
        pendingCount: Int = 0,
        lastSyncTime: Date? = nil,
        isSyncing: Bool = false
    ) {
        self.isOnline = isOnline
        self.pendingCount = pendingCount
        self.lastSyncTime = lastSyncTime
        self.isSyncing = isSyncing
    }
}
