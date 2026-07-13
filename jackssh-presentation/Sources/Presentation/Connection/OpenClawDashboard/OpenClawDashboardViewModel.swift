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
    private let portForwardLifecycleReporter: PortForwardLifecycleReporting
    private let sessionRegistry: PortForwardSessionRegistry

    public init(
        hostID: UUID,
        loadHosts: LoadHosts,
        openPortForward: OpenPortForward,
        resolveAuthToken: ResolveOpenClawAuthToken,
        portForwardLifecycleReporter: PortForwardLifecycleReporting = NoopPortForwardLifecycleReporter(),
        sessionRegistry: PortForwardSessionRegistry = PortForwardSessionRegistry()
    ) {
        self.hostID = hostID
        self.loadHosts = loadHosts
        self.openPortForward = openPortForward
        self.resolveAuthToken = resolveAuthToken
        self.portForwardLifecycleReporter = portForwardLifecycleReporter
        self.sessionRegistry = sessionRegistry
    }

    public func open() async {
        if let existingSession = sessionRegistry.session(for: hostID) {
            restore(existingSession)
            return
        }

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
                target: PortForwardTarget(host: config.host, port: config.port, preferredLocalPort: config.port),
                scheme: config.scheme,
                basePath: config.basePath
            )

            uiState.status = .preparingAuthentication
            let authToken = try await resolveAuthToken(for: host, configuration: config)
            guard let authToken, !authToken.isEmpty else {
                await session.stop()
                fail("OpenClaw token was not found on the VPS. Check /root/openclaw/data/credentials/openclaw-secrets.json and gateway.auth.token.")
                return
            }
            uiState.authToken = authToken

            guard let url = session.endpoint.localURL else {
                await session.stop()
                fail("Could not build local dashboard URL")
                return
            }

            let tunnelDescription = "iPad \(session.endpoint.localHost):\(session.endpoint.localPort) -> VPS \(session.endpoint.remoteHost):\(session.endpoint.remotePort)"
            let dashboardURL = Self.dashboardURL(url, authToken: authToken)
            sessionRegistry.register(
                RegisteredPortForwardSession(
                    host: host,
                    session: session,
                    endpoint: session.endpoint,
                    dashboardURL: dashboardURL,
                    tunnelDescription: tunnelDescription,
                    authToken: authToken
                ),
                for: hostID
            )
            uiState.dashboardURL = dashboardURL
            uiState.tunnelDescription = tunnelDescription
            uiState.status = .ready
            portForwardLifecycleReporter.portForwardStarted(
                host: host,
                endpoint: session.endpoint,
                tunnelDescription: tunnelDescription
            )
        } catch {
            fail(error.localizedDescription)
        }
    }

    public func close() async {
        portForwardLifecycleReporter.portForwardStopped()
        let registeredSession = sessionRegistry.removeSession(for: hostID)
        await registeredSession?.session.stop()
        uiState.dashboardURL = nil
        uiState.tunnelDescription = nil
        uiState.authToken = nil
        uiState.status = .idle
    }

    public func clearEffect() {
        effect = .none
    }

    private func fail(_ message: String) {
        portForwardLifecycleReporter.portForwardStopped()
        uiState.status = .failed(message)
        effect = .showError(message)
    }

    private func restore(_ registeredSession: RegisteredPortForwardSession) {
        uiState.host = registeredSession.host
        uiState.dashboardURL = registeredSession.dashboardURL
        uiState.tunnelDescription = registeredSession.tunnelDescription
        uiState.authToken = registeredSession.authToken
        uiState.status = .ready
        portForwardLifecycleReporter.portForwardStarted(
            host: registeredSession.host,
            endpoint: registeredSession.endpoint,
            tunnelDescription: registeredSession.tunnelDescription
        )
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
