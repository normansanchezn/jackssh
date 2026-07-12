import Foundation
import SwiftData
import Domain

/// SwiftData-backed `HostRepository`. `@ModelActor` gives it an isolated
/// `ModelContext`, so it is safe to use across concurrency domains.
@ModelActor
public actor SwiftDataHostRepository: HostRepository {
    public func all() async throws -> [Domain.Host] {
        let descriptor = FetchDescriptor<HostRecord>(sortBy: [SortDescriptor(\.name)])
        return try modelContext.fetch(descriptor).map(\.asDomain)
    }

    public func host(id: UUID) async throws -> Domain.Host? {
        try fetchRecord(id: id)?.asDomain
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
            existing.favoriteRemotePath = host.favoriteRemotePath
            existing.lastSuccessfulConnection = host.lastSuccessfulConnection
            existing.isFavorite = host.isFavorite
        } else {
            modelContext.insert(HostRecord(host))
        }
        try modelContext.save()
    }

    public func delete(id: UUID) async throws {
        guard let record = try fetchRecord(id: id) else { return }
        modelContext.delete(record)
        try modelContext.save()
    }

    private func fetchRecord(id: UUID) throws -> HostRecord? {
        let descriptor = FetchDescriptor<HostRecord>(predicate: #Predicate { $0.id == id })
        return try modelContext.fetch(descriptor).first
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
