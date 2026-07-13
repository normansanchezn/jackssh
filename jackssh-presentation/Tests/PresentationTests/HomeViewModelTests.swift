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

private struct HostsRepo: HostRepository {
    let hosts: [Domain.Host]

    func all() async throws -> [Domain.Host] { hosts }
    func host(id: UUID) async throws -> Domain.Host? { hosts.first { $0.id == id } }
    func save(_ host: Domain.Host) async throws {}
    func delete(id: UUID) async throws {}
}

private struct SessionStore: ConnectionSessionStore {
    let session: ConnectedHostSession?

    func activeSession(for hostID: UUID) async -> ConnectedHostSession? {
        session?.hostID == hostID ? session : nil
    }

    func mostRecentActiveSession() async -> ConnectedHostSession? { session }
    func activate(_ session: ConnectedHostSession) async {}
    func deactivate(hostID: UUID) async {}
}

private struct OpenClawLogsRepo: OpenClawLogRepository {
    let logs: [OpenClawLogEntry]

    func recentLogs(for host: Domain.Host, limit: Int) async throws -> [OpenClawLogEntry] {
        logs
    }
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

    @Test func exposesOpenClawForActiveSessionWhenConfigured() async {
        let hostID = UUID()
        let host = Domain.Host(
            id: hostID,
            name: "Production",
            hostname: "vps.example.com",
            username: "root",
            openClawConfiguration: OpenClawConfiguration(host: "127.0.0.1")
        )
        let session = ConnectedHostSession(
            hostID: hostID,
            hostname: host.hostname,
            username: host.username,
            port: host.port
        )
        let vm = HomeViewModel(
            loadHomeStatus: LoadHomeStatus(repository: SuccessRepo(status: makeStatus())),
            loadActiveSession: LoadActiveConnectionSession(store: SessionStore(session: session)),
            loadHosts: LoadHosts(repository: HostsRepo(hosts: [host]))
        )

        await vm.load()

        #expect(vm.hasOpenClawForActiveSession)
    }

    @Test func loadsOpenClawLogsForActiveConfiguredHost() async {
        let hostID = UUID()
        let host = Domain.Host(
            id: hostID,
            name: "Production",
            hostname: "vps.example.com",
            username: "root",
            openClawConfiguration: OpenClawConfiguration(host: "127.0.0.1")
        )
        let session = ConnectedHostSession(hostID: hostID, hostname: host.hostname, username: host.username, port: host.port)
        let logs = [
            OpenClawLogEntry(severity: .warning, message: "token refresh is slow", source: "openclaw"),
            OpenClawLogEntry(severity: .error, message: "failed to reach worker", source: "openclaw-api"),
            OpenClawLogEntry(severity: .success, message: "POST /api/generate 200", source: "ollama"),
        ]
        let vm = HomeViewModel(
            loadHomeStatus: LoadHomeStatus(repository: SuccessRepo(status: makeStatus())),
            loadActiveSession: LoadActiveConnectionSession(store: SessionStore(session: session)),
            loadHosts: LoadHosts(repository: HostsRepo(hosts: [host])),
            loadOpenClawLogs: LoadOpenClawLogs(repository: OpenClawLogsRepo(logs: logs))
        )

        await vm.load()

        #expect(vm.openClawLogs == logs)
    }
}
