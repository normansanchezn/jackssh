import Foundation
import Security
import Domain

/// Keychain-backed credential storage for SSH authentication.
public actor KeychainCredentialStore: CredentialStore {
    private let service = "com.jackssh.credentials"

    public init() {}

    public func storePassword(_ password: String, for hostID: UUID) async throws {
        let key = "password:\(hostID)"
        guard let data = password.data(using: .utf8) else {
            throw DomainError.unknown
        }
        try await setSecret(data, for: key)
    }

    public func password(for hostID: UUID) async throws -> String? {
        let key = "password:\(hostID)"
        guard let data = try await secret(for: key) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    public func storePrivateKey(_ keyData: Data, for hostID: UUID) async throws {
        let key = "privatekey:\(hostID)"
        try await setSecret(keyData, for: key)
    }

    public func privateKey(for hostID: UUID) async throws -> Data? {
        let key = "privatekey:\(hostID)"
        return try await secret(for: key)
    }

    public func deleteCredentials(for hostID: UUID) async throws {
        try await removeSecret(for: "password:\(hostID)")
        try await removeSecret(for: "privatekey:\(hostID)")
    }

    private func secret(for key: String) async throws -> Data? {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecService as String: service,
            kSecAccount as String: key,
            kSecReturnData as String: true
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        switch status {
        case errSecSuccess:
            return result as? Data
        case errSecItemNotFound:
            return nil
        default:
            throw DomainError.unknown
        }
    }

    private func setSecret(_ value: Data, for key: String) async throws {
        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecService as String: service,
            kSecAccount as String: key
        ]
        SecItemDelete(deleteQuery as CFDictionary)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecService as String: service,
            kSecAccount as String: key,
            kSecValueData as String: value,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else { throw DomainError.unknown }
    }

    private func removeSecret(for key: String) async throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecService as String: service,
            kSecAccount as String: key
        ]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw DomainError.unknown
        }
    }
}

/// Add CredentialStore protocol to Domain/Repositories/Repositories.swift:
/// public protocol CredentialStore: Sendable {
///     func storePassword(_ password: String, for hostID: UUID) async throws
///     func password(for hostID: UUID) async throws -> String?
///     func storePrivateKey(_ keyData: Data, for hostID: UUID) async throws
///     func privateKey(for hostID: UUID) async throws -> Data?
///     func deleteCredentials(for hostID: UUID) async throws
/// }
