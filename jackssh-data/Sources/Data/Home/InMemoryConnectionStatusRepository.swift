import Foundation
import Domain

/// In-memory connection status repository for development/testing.
public actor InMemoryConnectionStatusRepository: ConnectionStatusRepository {
    private var statuses: [UUID: ConnectionStatus] = [:]

    public init() {}

    public func status(for hostID: UUID) async throws -> ConnectionStatus? {
        return statuses[hostID]
    }

    public func setStatus(_ status: ConnectionStatus) async throws {
        statuses[status.hostID] = status
    }

    public func clearStatus(for hostID: UUID) async throws {
        statuses.removeValue(forKey: hostID)
    }
}
