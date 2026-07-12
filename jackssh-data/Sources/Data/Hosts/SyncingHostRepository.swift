import Foundation
import Domain

/// Bridges the previous local-only storage with the Supabase-backed store.
/// Local SwiftData is the source of truth for this device. Supabase is a sync
/// replica used to hydrate new devices and publish local changes when available.
public actor SyncingHostRepository: HostRepository {
    private let local: HostRepository
    private let remote: HostRepository

    public init(local: HostRepository, remote: HostRepository) {
        self.local = local
        self.remote = remote
    }

    public func all() async throws -> [Domain.Host] {
        let localHosts = try await local.all()

        do {
            let remoteHosts = try await remote.all()
            let merged = merge(local: localHosts, remote: remoteHosts)

            for host in localHosts {
                try? await remote.save(host)
            }

            for host in merged {
                try await local.save(host)
            }

            return sort(merged)
        } catch {
            return sort(localHosts)
        }
    }

    public func host(id: UUID) async throws -> Domain.Host? {
        if let host = try await local.host(id: id) {
            try? await remote.save(host)
            return host
        }

        guard let host = try? await remote.host(id: id) else { return nil }
        try await local.save(host)
        return host
    }

    public func save(_ host: Domain.Host) async throws {
        try await local.save(host)
        try? await remote.save(host)
    }

    public func delete(id: UUID) async throws {
        try await local.delete(id: id)
        try? await remote.delete(id: id)
    }

    private func merge(local: [Domain.Host], remote: [Domain.Host]) -> [Domain.Host] {
        var byID = Dictionary(uniqueKeysWithValues: remote.map { ($0.id, $0) })
        for host in local {
            byID[host.id] = host
        }
        return Array(byID.values)
    }

    private func sort(_ hosts: [Domain.Host]) -> [Domain.Host] {
        hosts.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
}
