import Testing
import Foundation
import Domain
@testable import Presentation

private actor CapturingHostRepository: HostRepository {
    private(set) var saved: [Domain.Host] = []
    func all() async throws -> [Domain.Host] { saved }
    func host(id: UUID) async throws -> Domain.Host? { saved.first { $0.id == id } }
    func save(_ host: Domain.Host) async throws { saved.append(host) }
    func delete(id: UUID) async throws {}
    func savedCount() -> Int { saved.count }
}

@MainActor
@Suite("HostEditorViewModel")
struct HostEditorViewModelTests {
    @Test func savesValidDraft() async {
        let repo = CapturingHostRepository()
        let vm = HostEditorViewModel(saveHost: SaveHost(repository: repo))
        vm.name = "VPS"
        vm.hostname = "vps.example"
        vm.port = "2222"
        vm.username = "root"

        let saved = await vm.save()
        #expect(saved?.port == 2222)
        #expect(vm.issues.isEmpty)
        #expect(await repo.savedCount() == 1)
    }

    @Test func surfacesValidationIssuesAndDoesNotSave() async {
        let repo = CapturingHostRepository()
        let vm = HostEditorViewModel(saveHost: SaveHost(repository: repo))
        vm.name = ""
        vm.hostname = ""
        vm.port = "abc"
        vm.username = ""

        let saved = await vm.save()
        #expect(saved == nil)
        #expect(vm.issue(for: .name) != nil)
        #expect(vm.issue(for: .port) != nil)
        #expect(await repo.savedCount() == 0)
    }

    @Test func editingPreservesIdentity() async {
        let repo = CapturingHostRepository()
        let existing = Domain.Host(name: "Old", hostname: "old", port: 22, username: "u")
        let vm = HostEditorViewModel(saveHost: SaveHost(repository: repo), host: existing)
        #expect(vm.isEditing)
        vm.name = "New"

        let saved = await vm.save()
        #expect(saved?.id == existing.id)
        #expect(saved?.name == "New")
    }
}
