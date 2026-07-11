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
    public var sshIdentityID: UUID?

    public init(
        id: UUID,
        name: String,
        hostname: String,
        port: Int,
        username: String,
        privateAddress: String?,
        tags: [String],
        sshIdentityID: UUID?
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

extension HostRecord {
    convenience init(_ host: Domain.Host) {
        self.init(
            id: host.id,
            name: host.name,
            hostname: host.hostname,
            port: host.port,
            username: host.username,
            privateAddress: host.privateAddress,
            tags: host.tags,
            sshIdentityID: host.sshIdentityID
        )
    }

    var asDomain: Domain.Host {
        Domain.Host(
            id: id,
            name: name,
            hostname: hostname,
            port: port,
            username: username,
            privateAddress: privateAddress,
            tags: tags,
            sshIdentityID: sshIdentityID
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
