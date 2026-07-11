import Foundation
import Security
import Domain

/// `SecretStore` backed by the iOS Keychain.
///
/// - Items use `kSecClassGenericPassword`, scoped by `service`.
/// - Accessibility is `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`: secrets
///   never leave the device and are unavailable while locked.
/// - No secret is ever logged.
public struct KeychainSecretStore: SecretStore {
    private let service: String

    public init(service: String = "dev.normansanchez.JackSsh") {
        self.service = service
    }

    public func secret(for key: String) async throws -> Data? {
        var query = baseQuery(for: key)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        switch status {
        case errSecSuccess:
            return item as? Data
        case errSecItemNotFound:
            return nil
        default:
            throw KeychainError(status: status).asDomainError
        }
    }

    public func setSecret(_ value: Data, for key: String) async throws {
        // Try update first; insert if absent. Avoids duplicate-item errors.
        let attributes = [kSecValueData as String: value] as CFDictionary
        let updateStatus = SecItemUpdate(baseQuery(for: key) as CFDictionary, attributes)

        switch updateStatus {
        case errSecSuccess:
            return
        case errSecItemNotFound:
            var insert = baseQuery(for: key)
            insert[kSecValueData as String] = value
            insert[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
            let addStatus = SecItemAdd(insert as CFDictionary, nil)
            guard addStatus == errSecSuccess else {
                throw KeychainError(status: addStatus).asDomainError
            }
        default:
            throw KeychainError(status: updateStatus).asDomainError
        }
    }

    public func removeSecret(for key: String) async throws {
        let status = SecItemDelete(baseQuery(for: key) as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError(status: status).asDomainError
        }
    }

    private func baseQuery(for key: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
        ]
    }
}

/// Thin wrapper over a Keychain `OSStatus` for mapping into the domain taxonomy.
public struct KeychainError: Error, Equatable {
    public let status: OSStatus

    public var asDomainError: DomainError {
        switch status {
        case errSecItemNotFound: return .notFound
        case errSecAuthFailed, errSecUserCanceled: return .unauthorized
        default: return .unknown
        }
    }
}
