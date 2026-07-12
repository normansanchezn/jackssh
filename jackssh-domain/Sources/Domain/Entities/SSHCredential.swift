import Foundation

/// Authentication method for SSH connection.
public enum SSHAuthMethod: Equatable, Sendable {
    case password(String)
    case publicKey(keyID: UUID)
}

/// Metadata for SSH public key (stored in Keychain, key material separate).
public struct SSHPublicKey: Equatable, Sendable {
    public let id: UUID
    public let name: String
    public let fingerprint: String?

    public init(id: UUID = UUID(), name: String, fingerprint: String? = nil) {
        self.id = id
        self.name = name
        self.fingerprint = fingerprint
    }
}

/// Secure credential reference (host ID + secret key). Actual secret lives in Keychain.
public struct SecureCredentialRef: Equatable, Sendable {
    /// Keyed by: "host:\(hostID):auth"
    public let keychainKey: String

    public init(hostID: UUID) {
        self.keychainKey = "host:\(hostID):auth"
    }
}
