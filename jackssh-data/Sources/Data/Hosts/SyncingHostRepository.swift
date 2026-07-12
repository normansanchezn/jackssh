import Foundation
import Domain

/// Bridges the previous local-only storage with the Supabase-backed store.
/// Remote is the shared source of truth; local SwiftData remains a device cache
/// and a one-time migration source for hosts created before remote sync existed.
public actor SyncingHostRepository: HostRepository {
    private let local: HostRepository
    private let remote: HostRepository

    public init(local: HostRepository, remote: HostRepository) {
        self.local = local
        self.remote = remote
    }

    public func all() async throws -> [Domain.Host] {
        let remoteHosts = try await remote.all()
        let localHosts = try await local.all()

        let remoteIDs = Set(remoteHosts.map(\.id))
        let localOnlyHosts = localHosts.filter { !remoteIDs.contains($0.id) }

        for host in localOnlyHosts {
            try await remote.save(host)
        }

        let merged = merge(remoteHosts + localOnlyHosts)
        for host in merged {
            try await local.save(host)
        }
        return merged.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    public func host(id: UUID) async throws -> Domain.Host? {
        if let host = try await remote.host(id: id) {
            try await local.save(host)
            return host
        }

        guard let host = try await local.host(id: id) else { return nil }
        try await remote.save(host)
        return host
    }

    public func save(_ host: Domain.Host) async throws {
        try await remote.save(host)
        try await local.save(host)
    }

    public func delete(id: UUID) async throws {
        try await remote.delete(id: id)
        try await local.delete(id: id)
    }

    private func merge(_ hosts: [Domain.Host]) -> [Domain.Host] {
        var byID: [UUID: Domain.Host] = [:]
        for host in hosts {
            byID[host.id] = host
        }
        return Array(byID.values)
    }
}
