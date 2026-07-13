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
    /// SSH authentication method (password stored in Keychain, key ID here).
    public var authenticationMethod: SSHAuthMethod
    /// Optional OpenClaw dashboard configuration.
    public var openClawConfiguration: OpenClawConfiguration?
    /// Optional favorite remote directory to open on connection.
    public var favoriteRemotePath: String?
    /// Favorite remote directories shown as quick routes in the file browser.
    public var favoriteRemotePaths: [String]
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
        authenticationMethod: SSHAuthMethod = .password,
        openClawConfiguration: OpenClawConfiguration? = nil,
        favoriteRemotePath: String? = nil,
        favoriteRemotePaths: [String] = [],
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
        let normalizedFavoritePaths = Self.normalizedFavoritePaths(
            favoriteRemotePaths,
            fallback: favoriteRemotePath
        )
        self.favoriteRemotePath = normalizedFavoritePaths.first
        self.favoriteRemotePaths = normalizedFavoritePaths
        self.lastSuccessfulConnection = lastSuccessfulConnection
        self.isFavorite = isFavorite
    }

    public var primaryFavoriteRemotePath: String? {
        favoriteRemotePaths.first ?? favoriteRemotePath
    }

    private static func normalizedFavoritePaths(_ paths: [String], fallback: String?) -> [String] {
        var seen = Set<String>()
        let candidates = paths + [fallback].compactMap { $0 }
        return candidates.compactMap { path in
            let trimmed = path.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return nil }
            let normalized = trimmed.hasPrefix("/") ? trimmed : "/\(trimmed)"
            guard !seen.contains(normalized) else { return nil }
            seen.insert(normalized)
            return normalized
        }
    }
}
