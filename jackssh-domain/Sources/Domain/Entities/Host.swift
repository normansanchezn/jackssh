import Foundation

/// A managed SSH host. Non-sensitive: secrets (keys, passwords) live in the Keychain, keyed by `id`.
public struct Host: Identifiable, Sendable {
    public let id: UUID
    public var name: String
    public var hostname: String
    public var port: Int
    public var username: String
    /// Private/Tailscale address used to reach management endpoints. Optional.
    public var privateAddress: String?
    public var tags: [String]
    /// SSH authentication method (password stored in Keychain, key ID here).
    public var authenticationMethod: SSHAuthenticationMethod
    /// Optional OpenClaw dashboard configuration.
    public var openClawConfiguration: OpenClawConfiguration?
    /// Optional favorite remote directory to open on connection.
    public var favoriteRemotePath: String?
    /// Timestamp of last successful connection.
    public var lastSuccessfulConnection: Date?
    /// Whether this host is starred as a favorite.
    public var isFavorite: Bool

    public init(
        id: UUID = UUID(),
        name: String,
        hostname: String,
        port: Int = 22,
        username: String,
        privateAddress: String? = nil,
        tags: [String] = [],
        authenticationMethod: SSHAuthenticationMethod = .password(""),
        openClawConfiguration: OpenClawConfiguration? = nil,
        favoriteRemotePath: String? = nil,
        lastSuccessfulConnection: Date? = nil,
        isFavorite: Bool = false
    ) {
        self.id = id
        self.name = name
        self.hostname = hostname
        self.port = port
        self.username = username
        self.privateAddress = privateAddress
        self.tags = tags
        self.authenticationMethod = authenticationMethod
        self.openClawConfiguration = openClawConfiguration
        self.favoriteRemotePath = favoriteRemotePath
        self.lastSuccessfulConnection = lastSuccessfulConnection
        self.isFavorite = isFavorite
    }
}
