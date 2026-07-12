import Foundation
import Observation
import Domain

@MainActor
@Observable
public final class ConnectedHostViewModel {
    public private(set) var uiState = ConnectedHostUIState()
    public private(set) var effect: ConnectedHostEffect = .none
    public var session: ConnectedHostSession? { uiState.session }
    public var host: Domain.Host? { uiState.host }
    public var isLoading: Bool { uiState.isLoading }
    public var loadError: String? { uiState.loadError }

    private let hostID: UUID
    private let loadHost: LoadHosts
    private let loadActiveSession: LoadActiveConnectionSession
    private let endSession: EndConnectionSession

    public init(
        hostID: UUID,
        loadHost: LoadHosts,
        loadActiveSession: LoadActiveConnectionSession,
        endSession: EndConnectionSession
    ) {
        self.hostID = hostID
        self.loadHost = loadHost
        self.loadActiveSession = loadActiveSession
        self.endSession = endSession
    }

    public func load() async {
        do {
            let hosts = try await loadHost()
            uiState.host = hosts.first(where: { $0.id == hostID })
            uiState.session = await loadActiveSession(for: hostID)
            if uiState.host == nil {
                uiState.loadError = "Host not found"
                effect = .showError("Host not found")
            } else if uiState.session == nil {
                uiState.loadError = "This SSH session is no longer active"
                effect = .showError("This SSH session is no longer active")
            }
        } catch {
            uiState.loadError = error.localizedDescription
            effect = .showError(error.localizedDescription)
        }
        uiState.isLoading = false
    }

    public func disconnect() async {
        await endSession(for: hostID)
        uiState.session = nil
        effect = .disconnected
    }

    public func clearEffect() {
        effect = .none
    }
}
