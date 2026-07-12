import Foundation
import Observation
import Domain

@MainActor
@Observable
public final class ConnectingHostViewModel {
    public private(set) var state: HostConnectionState = .idle
    public private(set) var host: Domain.Host?
    public private(set) var error: String?

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
            state = .resolving
            let hosts = try await loadHost()
            guard let host = hosts.first(where: { $0.id == hostID }) else {
                state = .failed(HostConnectionFailure(kind: .invalidConfiguration("Host not found")))
                return
            }
            self.host = host

            state = .authenticating
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
                state = .connected(session)
            case let .authenticationFailed(msg):
                state = .failed(HostConnectionFailure(kind: .authenticationFailed(msg)))
            case let .hostUnreachable(msg):
                state = .failed(HostConnectionFailure(kind: .hostUnreachable(msg), canRetry: true))
            case .timeout:
                state = .failed(HostConnectionFailure(kind: .other("Connection timed out"), canRetry: true))
            case let .hostKeyVerificationRequired(key):
                state = .verifyingHostKey(fingerprint: key)
            case let .hostKeyChanged(msg):
                state = .failed(HostConnectionFailure(kind: .hostKeyChanged(msg), canRetry: false))
            case let .failed(msg):
                state = .failed(HostConnectionFailure(kind: .other(msg)))
            }
        } catch {
            state = .failed(HostConnectionFailure(kind: .other("Connection failed: \(error.localizedDescription)")))
        }
    }

    public func cancel() {
        state = .cancelled
    }

    public func retry() async {
        state = .idle
        await connect()
    }
}
