import Foundation

/// A managed SSH host. Non-sensitive: secrets (keys, passwords) live in the Keychain, keyed by `id`.
public struct Host: Identifiable, Equatable, Sendable {
    public let id: UUID
    public var name: String
    public var hostname: String
    public var port: Int
    public var username: String
    /// Private/Tailscale address used to reach management endpoints. Optional.
    public var privateAddress: String?
    public var tags: [String]
    /// Identifier of the SSH identity (key) to authenticate with, if any.
    public var sshIdentityID: UUID?

    public init(
        id: UUID = UUID(),
        name: String,
        hostname: String,
        port: Int = 22,
        username: String,
        privateAddress: String? = nil,
        tags: [String] = [],
        sshIdentityID: UUID? = nil
    ) {
        self.id = id
        self.name = name
        self.hostname = hostname
        self.port = port
        self.username = username
        self.privateAddress = privateAddress
        self.tags = tags
        self.sshIdentityID = sshIdentityID
    }
}
