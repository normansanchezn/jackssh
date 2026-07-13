import Foundation
import SwiftData
import Domain

/// SwiftData-backed `HostRepository`. `@ModelActor` gives it an isolated
/// `ModelContext`, so it is safe to use across concurrency domains.
@ModelActor
public actor SwiftDataHostRepository: HostRepository {
    public func all() async throws -> [Domain.Host] {
        let descriptor = FetchDescriptor<HostRecord>(sortBy: [SortDescriptor(\.name)])
        let favoritePaths = try favoritePathsByHostID()
        return try modelContext.fetch(descriptor).map { record in
            record.asDomain(favoriteRemotePaths: favoritePaths[record.id] ?? [])
        }
    }

    public func host(id: UUID) async throws -> Domain.Host? {
        guard let record = try fetchRecord(id: id) else { return nil }
        return try record.asDomain(favoriteRemotePaths: favoritePaths(for: id))
    }

    public func save(_ host: Domain.Host) async throws {
        if let existing = try fetchRecord(id: host.id) {
            existing.name = host.name
            existing.hostname = host.hostname
            existing.port = host.port
            existing.username = host.username
            existing.privateAddress = host.privateAddress
            existing.tags = host.tags

            let (authMethodType, sshKeyID) = authMethodParts(host.authenticationMethod)
            existing.authMethodType = authMethodType
            existing.sshKeyID = sshKeyID

            existing.openClawHost = host.openClawConfiguration?.host
            existing.openClawPort = host.openClawConfiguration?.port ?? 18789
            existing.openClawScheme = host.openClawConfiguration?.scheme ?? "http"
            existing.openClawBasePath = host.openClawConfiguration?.basePath ?? "/"
            existing.favoriteRemotePath = host.primaryFavoriteRemotePath
            existing.lastSuccessfulConnection = host.lastSuccessfulConnection
            existing.isFavorite = host.isFavorite
            try replaceFavoritePaths(for: host)
        } else {
            modelContext.insert(HostRecord(host))
            try replaceFavoritePaths(for: host)
        }
        try modelContext.save()
    }

    public func delete(id: UUID) async throws {
        guard let record = try fetchRecord(id: id) else { return }
        for favorite in try favoriteRecords(for: id) {
            modelContext.delete(favorite)
        }
        modelContext.delete(record)
        try modelContext.save()
    }

    private func fetchRecord(id: UUID) throws -> HostRecord? {
        let descriptor = FetchDescriptor<HostRecord>(predicate: #Predicate { $0.id == id })
        return try modelContext.fetch(descriptor).first
    }

    private func favoritePathsByHostID() throws -> [UUID: [String]] {
        let descriptor = FetchDescriptor<FavoritePathRecord>(sortBy: [SortDescriptor(\.path)])
        let records = try modelContext.fetch(descriptor)
        return Dictionary(grouping: records, by: \.hostID)
            .mapValues { $0.map(\.path) }
    }

    private func favoritePaths(for hostID: UUID) throws -> [String] {
        try favoriteRecords(for: hostID).map(\.path)
    }

    private func favoriteRecords(for hostID: UUID) throws -> [FavoritePathRecord] {
        let descriptor = FetchDescriptor<FavoritePathRecord>(
            predicate: #Predicate { $0.hostID == hostID },
            sortBy: [SortDescriptor(\.path)]
        )
        return try modelContext.fetch(descriptor)
    }

    private func replaceFavoritePaths(for host: Domain.Host) throws {
        for favorite in try favoriteRecords(for: host.id) {
            modelContext.delete(favorite)
        }
        for path in host.favoriteRemotePaths {
            modelContext.insert(FavoritePathRecord(id: UUID(), hostID: host.id, path: path))
        }
    }

    private func authMethodParts(_ authMethod: Domain.SSHAuthMethod) -> (type: String, keyID: UUID?) {
        switch authMethod {
        case .password:
            return ("password", nil)
        case .publicKey(let keyID):
            return ("publicKey", keyID)
        }
    }
}
