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
    public var authToken: String? { uiState.authToken }

    private let hostID: UUID
    private let loadHosts: LoadHosts
    private let openPortForward: OpenPortForward
    private let resolveAuthToken: ResolveOpenClawAuthToken
    private var tunnelSession: PortForwardSession?

    public init(
        hostID: UUID,
        loadHosts: LoadHosts,
        openPortForward: OpenPortForward,
        resolveAuthToken: ResolveOpenClawAuthToken
    ) {
        self.hostID = hostID
        self.loadHosts = loadHosts
        self.openPortForward = openPortForward
        self.resolveAuthToken = resolveAuthToken
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

            uiState.status = .preparingAuthentication
            let authToken = try await resolveAuthToken(for: host, configuration: config)
            uiState.authToken = authToken

            guard let url = session.endpoint.localURL else {
                await session.stop()
                fail("Could not build local dashboard URL")
                return
            }

            tunnelSession = session
            uiState.dashboardURL = Self.dashboardURL(url, authToken: authToken)
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
        uiState.authToken = nil
        uiState.status = .idle
    }

    public func clearEffect() {
        effect = .none
    }

    private func fail(_ message: String) {
        uiState.status = .failed(message)
        effect = .showError(message)
    }

    private static func dashboardURL(_ url: URL, authToken: String?) -> URL {
        guard let authToken, !authToken.isEmpty,
              var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        else { return url }

        var queryItems = components.queryItems ?? []
        queryItems.append(URLQueryItem(name: "openclaw_token", value: authToken))
        queryItems.append(URLQueryItem(name: "token", value: authToken))
        components.queryItems = queryItems
        return components.url ?? url
    }
}
