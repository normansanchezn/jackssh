import Foundation
import Observation
import Domain

@MainActor
@Observable
public final class ConnectingHostViewModel {
    public private(set) var uiState = ConnectingHostUIState()
    public private(set) var effect: ConnectingHostEffect = .none
    public var state: HostConnectionState { uiState.state }
    public var host: Domain.Host? { uiState.host }
    public var error: String? { uiState.error }

    private let hostID: UUID
    private let loadHost: LoadHosts
    private let connectToHost: ConnectToHost
    private let activateSession: ActivateConnectionSession

    public init(
        hostID: UUID,
        loadHost: LoadHosts,
        connectToHost: ConnectToHost,
        activateSession: ActivateConnectionSession
    ) {
        self.hostID = hostID
        self.loadHost = loadHost
        self.connectToHost = connectToHost
        self.activateSession = activateSession
    }

    public func connect() async {
        do {
            uiState.state = .resolving
            let hosts = try await loadHost()
            guard let host = hosts.first(where: { $0.id == hostID }) else {
                let failure = HostConnectionFailure(kind: .invalidConfiguration("Host not found"))
                uiState.state = .failed(failure)
                uiState.error = failure.description
                effect = .showError(failure.description)
                return
            }
            uiState.host = host

            uiState.state = .authenticating
            let result = await connectToHost(to: host)

            switch result {
            case .success:
                let session = ConnectedHostSession(
                    hostID: host.id,
                    hostname: host.hostname,
                    username: host.username,
                    port: host.port
                )
                await activateSession(session)
                uiState.state = .connected(session)
                effect = .connected(session)
            case let .authenticationFailed(msg):
                fail(HostConnectionFailure(kind: .authenticationFailed(msg)))
            case let .hostUnreachable(msg):
                fail(HostConnectionFailure(kind: .hostUnreachable(msg), canRetry: true))
            case .timeout:
                fail(HostConnectionFailure(kind: .other("Connection timed out"), canRetry: true))
            case let .hostKeyVerificationRequired(key):
                uiState.state = .verifyingHostKey(fingerprint: key)
            case let .hostKeyChanged(msg):
                fail(HostConnectionFailure(kind: .hostKeyChanged(msg), canRetry: false))
            case let .failed(msg):
                fail(HostConnectionFailure(kind: .other(msg)))
            }
        } catch {
            fail(HostConnectionFailure(kind: .other("Connection failed: \(error.localizedDescription)")))
        }
    }

    public func cancel() {
        uiState.state = .cancelled
        effect = .cancelled
    }

    public func retry() async {
        uiState.state = .idle
        uiState.error = nil
        await connect()
    }

    public func clearEffect() {
        effect = .none
    }

    private func fail(_ failure: HostConnectionFailure) {
        uiState.state = .failed(failure)
        uiState.error = failure.description
        effect = .showError(failure.description)
    }
}
