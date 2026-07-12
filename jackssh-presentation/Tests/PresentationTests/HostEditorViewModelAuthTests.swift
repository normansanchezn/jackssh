import Testing
import Domain
@testable import Presentation

@Suite("HostEditorViewModelAuthTests")
struct HostEditorViewModelAuthTests {
    @Test("Switch to password auth shows password field")
    @MainActor
    func switchToPasswordAuth() {
        let viewModel = HostEditorViewModel(saveHost: SaveHostStub())
        viewModel.setAuthMethod(.password)
        #expect(viewModel.showPasswordField == true)
    }

    @Test("Switch to key auth hides password field")
    @MainActor
    func switchToKeyAuth() {
        let viewModel = HostEditorViewModel(saveHost: SaveHostStub())
        viewModel.setAuthMethod(.publicKey(keyID: UUID()))
        #expect(viewModel.showPasswordField == false)
    }
}

struct SaveHostStub: Sendable {
    func callAsFunction(_ draft: HostDraft, id: UUID) async throws -> Host {
        return Host(name: draft.name, hostname: draft.hostname, port: draft.port, username: draft.username)
    }
}
