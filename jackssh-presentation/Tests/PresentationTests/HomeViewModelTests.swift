import Testing
import Foundation
import Domain
@testable import Presentation

/// Test doubles for `HomeStatusRepository`.
private struct SuccessRepo: HomeStatusRepository {
    let status: HomeStatus
    func currentStatus() async throws -> HomeStatus { status }
}

private struct FailingRepo: HomeStatusRepository {
    let error: DomainError
    func currentStatus() async throws -> HomeStatus { throw error }
}

@MainActor
@Suite("HomeViewModel")
struct HomeViewModelTests {
    private func makeStatus() -> HomeStatus {
        HomeStatus(privateNetworkOnline: true, vps: .online, openClaw: .degraded,
                   ollama: .unknown, recentActivity: [])
    }

    @Test func startsIdle() {
        let vm = HomeViewModel(loadHomeStatus: LoadHomeStatus(repository: SuccessRepo(status: makeStatus())))
        #expect(vm.state == .idle)
    }

    @Test func loadsStatusIntoLoadedState() async {
        let status = makeStatus()
        let vm = HomeViewModel(loadHomeStatus: LoadHomeStatus(repository: SuccessRepo(status: status)))
        await vm.load()
        #expect(vm.state == .loaded(status))
    }

    @Test func mapsFailureToFailedState() async {
        let vm = HomeViewModel(loadHomeStatus: LoadHomeStatus(repository: FailingRepo(error: .offline)))
        await vm.load()
        #expect(vm.state == .failed(.offline))
    }
}
