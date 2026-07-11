import Testing
import Foundation
import Domain
import Shared
@testable import Data

private struct StubHTTPProbe: HTTPHealthProbe {
    let result: HealthState
    func probe(_ url: URL) async -> HealthState { result }
}

private struct StubSSHProbe: SSHHealthProbe {
    let result: HealthState
    func probe(_ target: SSHTarget) async -> HealthState { result }
}

@Suite("HealthProbingHomeStatusRepository")
struct HealthProbingHomeStatusRepositoryTests {
    private let fixed = FixedDateProvider(Date(timeIntervalSince1970: 42))

    @Test func unconfiguredTargetsResolveToUnknownAndOffline() async throws {
        let repo = HealthProbingHomeStatusRepository(
            configuration: .unconfigured,
            http: StubHTTPProbe(result: .online),   // not consulted: no URLs
            ssh: StubSSHProbe(result: .online),      // not consulted: no target
            dates: fixed
        )
        let status = try await repo.currentStatus()
        #expect(status.vps == .unknown)
        #expect(status.openClaw == .unknown)
        #expect(status.ollama == .unknown)
        #expect(status.privateNetworkOnline == false)
    }

    @Test func assemblesConfiguredProbeResults() async throws {
        let config = HomeProbeConfiguration(
            vps: SSHTarget(host: "10.0.0.2", username: "root"),
            openClaw: URL(string: "http://10.0.0.2:8080/health"),
            ollama: URL(string: "http://10.0.0.2:11434/")
        )
        let repo = HealthProbingHomeStatusRepository(
            configuration: config,
            http: StubHTTPProbe(result: .online),
            ssh: StubSSHProbe(result: .degraded),
            dates: fixed
        )
        let status = try await repo.currentStatus()
        #expect(status.vps == .degraded)
        #expect(status.openClaw == .online)
        #expect(status.ollama == .online)
        #expect(status.privateNetworkOnline)
        #expect(status.recentActivity.first?.timestamp == Date(timeIntervalSince1970: 42))
    }
}
