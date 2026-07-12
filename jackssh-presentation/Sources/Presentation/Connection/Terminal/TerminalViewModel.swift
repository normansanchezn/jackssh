import Foundation
import Observation
import Domain

/// Screen-level state for the interactive terminal: resolves the host, then
/// builds the `TerminalSession` that owns the live PTY. Holds no terminal
/// buffer of its own — SwiftTerm owns the buffer, the session owns the channel.
@MainActor
@Observable
public final class TerminalViewModel {
    public private(set) var uiState = TerminalUIState()
    public private(set) var effect: TerminalEffect = .none
    public var host: Domain.Host? { uiState.host }
    public var session: TerminalSession? { uiState.session }
    public var loadError: String? { uiState.loadError }

    private let hostID: UUID
    private let loadHosts: LoadHosts
    private let openTerminal: OpenTerminal
    private let activateSession: ActivateConnectionSession
    private let endSession: EndConnectionSession

    public init(
        hostID: UUID,
        loadHosts: LoadHosts,
        openTerminal: OpenTerminal,
        activateSession: ActivateConnectionSession,
        endSession: EndConnectionSession
    ) {
        self.hostID = hostID
        self.loadHosts = loadHosts
        self.openTerminal = openTerminal
        self.activateSession = activateSession
        self.endSession = endSession
    }

    /// Human-readable connection target, e.g. `root@108.174.154.104`.
    public var connectionTitle: String {
        uiState.connectionTitle
    }

    public func load() async {
        do {
            let hosts = try await loadHosts()
            guard let match = hosts.first(where: { $0.id == hostID }) else {
                uiState.loadError = "Host not found"
                effect = .showError("Host not found")
                return
            }
            uiState.host = match
            uiState.session = TerminalSession(
                host: match,
                openTerminal: openTerminal,
                activateSession: activateSession,
                endSession: endSession
            )
        } catch {
            uiState.loadError = error.localizedDescription
            effect = .showError(error.localizedDescription)
        }
    }

    public func clearEffect() {
        effect = .none
    }
}
