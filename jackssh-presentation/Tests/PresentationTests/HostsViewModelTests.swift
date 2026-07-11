import Testing
import Foundation
import Domain
@testable import Presentation

/// In-memory `HostRepository` double.
private actor FakeHostRepository: HostRepository {
    private var store: [UUID: Domain.Host] = [:]
    var deleteError: DomainError?

    init(seed: [Domain.Host] = []) {
        for host in seed { store[host.id] = host }
    }

    func all() async throws -> [Domain.Host] { store.values.sorted { $0.name < $1.name } }
    func host(id: UUID) async throws -> Domain.Host? { store[id] }
    func save(_ host: Domain.Host) async throws { store[host.id] = host }
    func delete(id: UUID) async throws {
        if let deleteError { throw deleteError }
        store[id] = nil
    }
}

private struct NoopSecretStore: SecretStore {
    func secret(for key: String) async throws -> Data? { nil }
    func setSecret(_ value: Data, for key: String) async throws {}
    func removeSecret(for key: String) async throws {}
}

@MainActor
@Suite("HostsViewModel")
struct HostsViewModelTests {
    private func makeViewModel(repo: FakeHostRepository) -> HostsViewModel {
        HostsViewModel(
            loadHosts: LoadHosts(repository: repo),
            deleteHost: DeleteHost(repository: repo, secrets: NoopSecretStore())
        )
    }

    @Test func loadsHosts() async {
        let repo = FakeHostRepository(seed: [
            Domain.Host(name: "Beta", hostname: "b", username: "u"),
            Domain.Host(name: "Alpha", hostname: "a", username: "u"),
        ])
        let vm = makeViewModel(repo: repo)
        await vm.load()
        #expect(vm.hosts.map(\.name) == ["Alpha", "Beta"])
    }

    @Test func deleteRemovesHostAndReloads() async {
        let host = Domain.Host(name: "Gone", hostname: "g", username: "u")
        let repo = FakeHostRepository(seed: [host])
        let vm = makeViewModel(repo: repo)
        await vm.load()
        #expect(vm.hosts.count == 1)
        await vm.delete(id: host.id)
        #expect(vm.hosts.isEmpty)
    }
}
