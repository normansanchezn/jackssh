import Testing
import Foundation
import Domain
@testable import Data

@Suite("SyncingHostRepository")
struct SyncingHostRepositoryTests {
    @Test func returnsLocalHostsWhenRemoteLoadFails() async throws {
        let local = MemoryHostRepository(hosts: [
            Domain.Host(name: "Local VPS", hostname: "local.example", username: "root")
        ])
        let remote = MemoryHostRepository(failure: .offline)
        let repository = SyncingHostRepository(local: local, remote: remote)

        let hosts = try await repository.all()

        #expect(hosts.count == 1)
        #expect(hosts.first?.name == "Local VPS")
    }

    @Test func savesLocalHostEvenWhenRemoteSaveFails() async throws {
        let local = MemoryHostRepository()
        let remote = MemoryHostRepository(failure: .offline)
        let repository = SyncingHostRepository(local: local, remote: remote)
        let host = Domain.Host(name: "Primary", hostname: "primary.example", username: "root")

        try await repository.save(host)

        #expect(try await local.host(id: host.id) == host)
    }

    @Test func hydratesLocalCacheFromRemoteWhenLocalIsEmpty() async throws {
        let remoteHost = Domain.Host(name: "Remote VPS", hostname: "remote.example", username: "root")
        let local = MemoryHostRepository()
        let remote = MemoryHostRepository(hosts: [remoteHost])
        let repository = SyncingHostRepository(local: local, remote: remote)

        let hosts = try await repository.all()

        #expect(hosts == [remoteHost])
        #expect(try await local.host(id: remoteHost.id) == remoteHost)
    }

    @Test func localVersionWinsWhenBothStoresHaveSameHost() async throws {
        let id = UUID()
        let localHost = Domain.Host(id: id, name: "Local Name", hostname: "local.example", username: "root")
        let remoteHost = Domain.Host(id: id, name: "Remote Name", hostname: "remote.example", username: "root")
        let local = MemoryHostRepository(hosts: [localHost])
        let remote = MemoryHostRepository(hosts: [remoteHost])
        let repository = SyncingHostRepository(local: local, remote: remote)

        let hosts = try await repository.all()

        #expect(hosts == [localHost])
        #expect(try await remote.host(id: id) == localHost)
    }
}

private actor MemoryHostRepository: HostRepository {
    private var hosts: [UUID: Domain.Host]
    private let failure: DomainError?

    init(hosts: [Domain.Host] = [], failure: DomainError? = nil) {
        self.hosts = Dictionary(uniqueKeysWithValues: hosts.map { ($0.id, $0) })
        self.failure = failure
    }

    func all() async throws -> [Domain.Host] {
        if let failure { throw failure }
        return Array(hosts.values)
    }

    func host(id: UUID) async throws -> Domain.Host? {
        if let failure { throw failure }
        return hosts[id]
    }

    func save(_ host: Domain.Host) async throws {
        if let failure { throw failure }
        hosts[host.id] = host
    }

    func delete(id: UUID) async throws {
        if let failure { throw failure }
        hosts[id] = nil
    }
}
