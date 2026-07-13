import Foundation
import Observation
import Domain

@MainActor
@Observable
public final class OpenClawDashboardViewModel {
    public private(set) var uiState = OpenClawDashboardUIState()
    public private(set) var effect: OpenClawDashboardEffect = .none

    public var host: Domain.Host? { uiState.host }
    public var status: OpenClawDashboardStatus { uiState.status }
    public var dashboardURL: URL? { uiState.dashboardURL }
    public var tunnelDescription: String? { uiState.tunnelDescription }

    private let hostID: UUID
    private let loadHosts: LoadHosts
    private let openPortForward: OpenPortForward
    private var tunnelSession: PortForwardSession?

    public init(
        hostID: UUID,
        loadHosts: LoadHosts,
        openPortForward: OpenPortForward
    ) {
        self.hostID = hostID
        self.loadHosts = loadHosts
        self.openPortForward = openPortForward
    }

    public func open() async {
        guard tunnelSession == nil else { return }
        uiState.status = .connectingTunnel

        do {
            let hosts = try await loadHosts()
            guard let host = hosts.first(where: { $0.id == hostID }) else {
                fail("Host not found")
                return
            }
            guard let config = host.openClawConfiguration else {
                fail("OpenClaw is not configured for this host")
                return
            }

            uiState.host = host
            let session = try await openPortForward(
                to: host,
                target: PortForwardTarget(host: config.host, port: config.port),
                scheme: config.scheme,
                basePath: config.basePath
            )

            guard let url = session.endpoint.localURL else {
                await session.stop()
                fail("Could not build local dashboard URL")
                return
            }

            tunnelSession = session
            uiState.dashboardURL = url
            uiState.tunnelDescription = "\(session.endpoint.localHost):\(session.endpoint.localPort) -> \(session.endpoint.remoteHost):\(session.endpoint.remotePort)"
            uiState.status = .ready
        } catch {
            fail(error.localizedDescription)
        }
    }

    public func close() async {
        await tunnelSession?.stop()
        tunnelSession = nil
        uiState.dashboardURL = nil
        uiState.tunnelDescription = nil
        uiState.status = .idle
    }

    public func clearEffect() {
        effect = .none
    }

    private func fail(_ message: String) {
        uiState.status = .failed(message)
        effect = .showError(message)
    }
}
