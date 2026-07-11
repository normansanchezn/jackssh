import Foundation
import Domain
import Shared

/// Real `HomeStatusRepository`: assembles the Home snapshot from live probes.
///
/// Probes run concurrently. Each target is optional — an unconfigured target
/// resolves to `.unknown` (nothing is invented). "Private network online" is
/// inferred from whether any configured probe was actually reachable, since
/// management endpoints live behind Tailscale.
public struct HealthProbingHomeStatusRepository: HomeStatusRepository {
    private let configuration: HomeProbeConfiguration
    private let http: HTTPHealthProbe
    private let ssh: SSHHealthProbe
    private let dates: DateProviding

    public init(
        configuration: HomeProbeConfiguration,
        http: HTTPHealthProbe,
        ssh: SSHHealthProbe,
        dates: DateProviding = SystemDateProvider()
    ) {
        self.configuration = configuration
        self.http = http
        self.ssh = ssh
        self.dates = dates
    }

    public func currentStatus() async throws -> HomeStatus {
        async let vps = probeVPS()
        async let openClaw = probeHTTP(configuration.openClaw)
        async let ollama = probeHTTP(configuration.ollama)

        let (vpsState, openClawState, ollamaState) = await (vps, openClaw, ollama)

        let reachable = [vpsState, openClawState, ollamaState].contains { $0 == .online || $0 == .degraded }

        return HomeStatus(
            privateNetworkOnline: reachable,
            vps: vpsState,
            openClaw: openClawState,
            ollama: ollamaState,
            recentActivity: [
                ActivityEvent(title: "Status refreshed", timestamp: dates.now(),
                              state: reachable ? .online : .unknown)
            ]
        )
    }

    private func probeHTTP(_ url: URL?) async -> HealthState {
        guard let url else { return .unknown }
        return await http.probe(url)
    }

    private func probeVPS() async -> HealthState {
        guard let target = configuration.vps else { return .unknown }
        return await ssh.probe(target)
    }
}
