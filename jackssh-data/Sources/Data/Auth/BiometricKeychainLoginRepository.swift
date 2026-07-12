import Foundation
import Security
import Domain

#if canImport(LocalAuthentication)
import LocalAuthentication
#endif

public actor BiometricKeychainLoginRepository: BiometricLoginRepository {
    private let service: String
    private let credentialKey = "supabase.auth.biometric.credentials"
    private let markerKey = "supabase.auth.biometric.marker"

    public init(service: String = "dev.normansanchez.JackSsh.biometric-login") {
        self.service = service
    }

    public func availability() async -> BiometricLoginAvailability {
        let marker = storedMarker()
        return BiometricLoginAvailability(
            isAvailable: canUseBiometrics(),
            isEnabled: marker != nil,
            biometryName: biometryName(),
            email: marker?.email
        )
    }

    public func save(email: String, password: String) async throws {
        guard canUseBiometrics() else { throw DomainError.unauthorized }
        let payload = StoredBiometricCredentials(email: email, password: password)
        let data = try JSONEncoder().encode(payload)

        try removeItem(for: credentialKey)
        try addProtectedCredential(data)
        try setMarker(StoredBiometricMarker(email: email))
    }

    public func credentials() async throws -> BiometricLoginCredentials {
        var query = baseQuery(for: credentialKey)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        #if canImport(LocalAuthentication)
        let context = LAContext()
        context.localizedReason = "Use biometrics to sign in to JackSSH"
        query[kSecUseAuthenticationContext as String] = context
        #endif

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let data = item as? Data else {
            throw KeychainError(status: status).asDomainError
        }

        let decoded = try JSONDecoder().decode(StoredBiometricCredentials.self, from: data)
        return BiometricLoginCredentials(email: decoded.email, password: decoded.password)
    }

    public func delete() async throws {
        try removeItem(for: credentialKey)
        try removeItem(for: markerKey)
    }

    private func addProtectedCredential(_ data: Data) throws {
        var error: Unmanaged<CFError>?
        guard let accessControl = SecAccessControlCreateWithFlags(
            nil,
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            .biometryCurrentSet,
            &error
        ) else {
            throw DomainError.unauthorized
        }

        var query = baseQuery(for: credentialKey)
        query[kSecValueData as String] = data
        query[kSecAttrAccessControl as String] = accessControl

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError(status: status).asDomainError
        }
    }

    private func setMarker(_ marker: StoredBiometricMarker) throws {
        let data = try JSONEncoder().encode(marker)
        try removeItem(for: markerKey)

        var query = baseQuery(for: markerKey)
        query[kSecValueData as String] = data
        query[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError(status: status).asDomainError
        }
    }

    private func storedMarker() -> StoredBiometricMarker? {
        var query = baseQuery(for: markerKey)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var item: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
              let data = item as? Data else {
            return nil
        }
        return try? JSONDecoder().decode(StoredBiometricMarker.self, from: data)
    }

    private func removeItem(for key: String) throws {
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

    private func canUseBiometrics() -> Bool {
        #if canImport(LocalAuthentication)
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        #else
        return false
        #endif
    }

    private func biometryName() -> String {
        #if canImport(LocalAuthentication)
        let context = LAContext()
        var error: NSError?
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        switch context.biometryType {
        case .faceID:
            return "Face ID"
        case .touchID:
            return "Touch ID"
        case .opticID:
            return "Optic ID"
        default:
            return "biometrics"
        }
        #else
        return "biometrics"
        #endif
    }
}

private struct StoredBiometricCredentials: Codable, Sendable {
    let email: String
    let password: String
}

private struct StoredBiometricMarker: Codable, Sendable {
    let email: String
}
