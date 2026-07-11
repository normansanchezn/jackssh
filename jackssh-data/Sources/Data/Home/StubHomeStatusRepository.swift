import Foundation
import Domain
import Shared

/// Placeholder `HomeStatusRepository` for the foundation slice.
///
/// It invents no backend: it returns a deterministic local snapshot so the Home
/// UI can be built and tested. Real probes (SSH / HTTP health checks over
/// Tailscale) replace this later without touching Presentation.
public struct StubHomeStatusRepository: HomeStatusRepository {
    private let dates: DateProviding

    public init(dates: DateProviding = SystemDateProvider()) {
        self.dates = dates
    }

    public func currentStatus() async throws -> HomeStatus {
        let now = dates.now()
        return HomeStatus(
            privateNetworkOnline: true,
            vps: .unknown,
            openClaw: .unknown,
            ollama: .unknown,
            recentActivity: [
                ActivityEvent(title: "Console ready", timestamp: now, state: .online)
            ]
        )
    }
}
