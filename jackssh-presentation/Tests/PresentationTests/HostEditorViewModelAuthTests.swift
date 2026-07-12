import Testing
import Foundation
import Domain
@testable import Presentation

@Suite("HostEditorViewModelAuthTests")
struct HostEditorViewModelAuthTests {
    @Test("Switch to password auth shows password field")
    @MainActor
    func switchToPasswordAuth() {
        let viewModel = HostEditorViewModel(saveHost: makeSaveHost())
        viewModel.setAuthMethod(.password)
        #expect(viewModel.showPasswordField == true)
    }

    @Test("Switch to key auth hides password field")
    @MainActor
    func switchToKeyAuth() {
        let viewModel = HostEditorViewModel(saveHost: makeSaveHost())
        viewModel.setAuthMethod(.publicKey(keyID: UUID()))
        #expect(viewModel.showPasswordField == false)
    }
}

private func makeSaveHost() -> SaveHost {
    SaveHost(repository: EmptyHostRepository(), secretStore: EmptySecretStore())
}

private actor EmptyHostRepository: HostRepository {
    func all() async throws -> [Domain.Host] { [] }
    func host(id: UUID) async throws -> Domain.Host? { nil }
    func save(_ host: Domain.Host) async throws {}
    func delete(id: UUID) async throws {}
}

private actor EmptySecretStore: SecretStore {
    func secret(for key: String) async throws -> Data? { nil }
    func setSecret(_ value: Data, for key: String) async throws {}
    func removeSecret(for key: String) async throws {}
}
