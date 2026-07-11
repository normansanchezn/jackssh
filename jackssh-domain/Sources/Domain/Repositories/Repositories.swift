import Foundation

/// Supplies the aggregated Home snapshot. Implemented in Data.
public protocol HomeStatusRepository: Sendable {
    func currentStatus() async throws -> HomeStatus
}

/// CRUD for managed hosts (non-sensitive fields). Implemented in Data over SwiftData.
public protocol HostRepository: Sendable {
    func all() async throws -> [Host]
    func host(id: UUID) async throws -> Host?
    func save(_ host: Host) async throws
    func delete(id: UUID) async throws
}

/// Abstraction over secure secret storage (Keychain / Secure Enclave). Implemented in Data.
/// Domain never sees the storage mechanism — only get/set/delete of opaque secrets.
public protocol SecretStore: Sendable {
    func secret(for key: String) async throws -> Data?
    func setSecret(_ value: Data, for key: String) async throws
    func removeSecret(for key: String) async throws
}
