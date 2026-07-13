import Foundation
import SwiftData
import Domain

/// SwiftData persistence models. Only non-sensitive data is stored here —
/// secrets live in the Keychain (`KeychainSecretStore`), never in SwiftData.

@Model
public final class HostRecord {
    @Attribute(.unique) public var id: UUID
    public var name: String
    public var hostname: String
    public var port: Int
    public var username: String
    public var privateAddress: String?
    public var tags: [String]
    public var authMethodType: String
    public var sshKeyID: UUID?
    public var openClawHost: String?
    public var openClawPort: Int
    public var openClawScheme: String
    public var openClawBasePath: String
    public var favoriteRemotePath: String?
    public var lastSuccessfulConnection: Date?
    public var isFavorite: Bool

    public init(
        id: UUID,
        name: String,
        hostname: String,
        port: Int,
        username: String,
        privateAddress: String?,
        tags: [String],
        authMethodType: String = "password",
        sshKeyID: UUID? = nil,
        openClawHost: String? = nil,
        openClawPort: Int = 18789,
        openClawScheme: String = "http",
        openClawBasePath: String = "/",
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
        self.authMethodType = authMethodType
        self.sshKeyID = sshKeyID
        self.openClawHost = openClawHost
        self.openClawPort = openClawPort
        self.openClawScheme = openClawScheme
        self.openClawBasePath = openClawBasePath
        self.favoriteRemotePath = favoriteRemotePath
        self.lastSuccessfulConnection = lastSuccessfulConnection
        self.isFavorite = isFavorite
    }
}

extension HostRecord {
    convenience init(_ host: Domain.Host) {
        let authMethodType: String
        var sshKeyID: UUID? = nil

        switch host.authenticationMethod {
        case .password:
            authMethodType = "password"
        case .publicKey(let keyID):
            authMethodType = "publicKey"
            sshKeyID = keyID
        }

        let openClawHost = host.openClawConfiguration?.host
        let openClawPort = host.openClawConfiguration?.port ?? 18789
        let openClawScheme = host.openClawConfiguration?.scheme ?? "http"
        let openClawBasePath = host.openClawConfiguration?.basePath ?? "/"

        self.init(
            id: host.id,
            name: host.name,
            hostname: host.hostname,
            port: host.port,
            username: host.username,
            privateAddress: host.privateAddress,
            tags: host.tags,
            authMethodType: authMethodType,
            sshKeyID: sshKeyID,
            openClawHost: openClawHost,
            openClawPort: openClawPort,
            openClawScheme: openClawScheme,
            openClawBasePath: openClawBasePath,
            favoriteRemotePath: host.primaryFavoriteRemotePath,
            lastSuccessfulConnection: host.lastSuccessfulConnection,
            isFavorite: host.isFavorite
        )
    }

    func asDomain(favoriteRemotePaths: [String] = []) -> Domain.Host {
        let authMethod: Domain.SSHAuthMethod
        if authMethodType == "publicKey", let keyID = sshKeyID {
            authMethod = .publicKey(keyID: keyID)
        } else {
            authMethod = .password
        }

        let openClawConfig: Domain.OpenClawConfiguration?
        if let host = openClawHost {
            openClawConfig = Domain.OpenClawConfiguration(
                host: host,
                port: openClawPort,
                scheme: openClawScheme,
                basePath: openClawBasePath
            )
        } else {
            openClawConfig = nil
        }

        let orderedFavoritePaths = [favoriteRemotePath].compactMap { $0 } + favoriteRemotePaths

        return Domain.Host(
            id: id,
            name: name,
            hostname: hostname,
            port: port,
            username: username,
            privateAddress: privateAddress,
            tags: tags,
            authenticationMethod: authMethod,
            openClawConfiguration: openClawConfig,
            favoriteRemotePath: favoriteRemotePath,
            favoriteRemotePaths: orderedFavoritePaths,
            lastSuccessfulConnection: lastSuccessfulConnection,
            isFavorite: isFavorite
        )
    }
}

@Model
public final class ServiceDefinitionRecord {
    @Attribute(.unique) public var id: UUID
    public var kindRawValue: String
    public var displayName: String
    public var hostID: UUID?

    public init(id: UUID, kindRawValue: String, displayName: String, hostID: UUID?) {
        self.id = id
        self.kindRawValue = kindRawValue
        self.displayName = displayName
        self.hostID = hostID
    }
}

@Model
public final class FavoritePathRecord {
    @Attribute(.unique) public var id: UUID
    public var hostID: UUID
    public var path: String

    public init(id: UUID, hostID: UUID, path: String) {
        self.id = id
        self.hostID = hostID
        self.path = path
    }
}

@Model
public final class EventRecord {
    @Attribute(.unique) public var id: UUID
    public var title: String
    public var timestamp: Date
    public var stateRawValue: String

    public init(id: UUID, title: String, timestamp: Date, stateRawValue: String) {
        self.id = id
        self.title = title
        self.timestamp = timestamp
        self.stateRawValue = stateRawValue
    }
}

@Model
public final class DashboardRecord {
    @Attribute(.unique) public var id: UUID
    public var title: String
    public var urlString: String

    public init(id: UUID, title: String, urlString: String) {
        self.id = id
        self.title = title
        self.urlString = urlString
    }
}
