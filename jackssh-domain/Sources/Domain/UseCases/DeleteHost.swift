import Foundation

/// Deletes a host and its associated secret material.
///
/// Removing the host's private key / password from the `SecretStore` is part of
/// the same operation so credentials never outlive the host they belong to.
public struct DeleteHost: Sendable {
    private let repository: HostRepository
    private let secrets: SecretStore

    public init(repository: HostRepository, secrets: SecretStore) {
        self.repository = repository
        self.secrets = secrets
    }

    public func callAsFunction(id: UUID) async throws {
        try await repository.delete(id: id)
        // Best-effort secret cleanup; a missing secret is not an error.
        try? await secrets.removeSecret(for: SecretKey.identity(hostID: id))
    }
}

/// Canonical Keychain key names, so producers and consumers never drift.
public enum SecretKey {
    public static func identity(hostID: UUID) -> String { "host.\(hostID.uuidString).identity" }
    public static func password(hostID: UUID) -> String { "host.\(hostID.uuidString).password" }
}
