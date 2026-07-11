import Foundation
import Domain

/// Non-persistent `SecretStore` for tests and SwiftUI previews.
/// Never use in production — provides no at-rest protection.
public actor InMemorySecretStore: SecretStore {
    private var storage: [String: Data]

    public init(seed: [String: Data] = [:]) {
        self.storage = seed
    }

    public func secret(for key: String) async throws -> Data? { storage[key] }
    public func setSecret(_ value: Data, for key: String) async throws { storage[key] = value }
    public func removeSecret(for key: String) async throws { storage[key] = nil }
}
