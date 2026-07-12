import Foundation
import Domain

/// In-memory credential storage stub (Keychain implementation in separate module).
public actor InMemoryCredentialStore: CredentialStore {
    private var passwords: [UUID: String] = [:]
    private var keys: [UUID: Data] = [:]

    public init() {}

    public func storePassword(_ password: String, for hostID: UUID) async throws {
        passwords[hostID] = password
    }

    public func password(for hostID: UUID) async throws -> String? {
        return passwords[hostID]
    }

    public func storePrivateKey(_ keyData: Data, for hostID: UUID) async throws {
        keys[hostID] = keyData
    }

    public func privateKey(for hostID: UUID) async throws -> Data? {
        return keys[hostID]
    }

    public func deleteCredentials(for hostID: UUID) async throws {
        passwords.removeValue(forKey: hostID)
        keys.removeValue(forKey: hostID)
    }
}
