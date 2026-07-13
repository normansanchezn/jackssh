import Foundation
import Observation
import Domain

/// Drives the Home screen. Holds no view code and no I/O — it calls the
/// `LoadHomeStatus` use case and exposes a simple, testable state machine.
@MainActor
@Observable
public final class HomeViewModel {
    public typealias ViewState = HomeUIState.ViewState

    public private(set) var uiState = HomeUIState()
    public private(set) var effect: HomeEffect = .none
    public var state: ViewState { uiState.state }
    public var activeSession: ConnectedHostSession? { uiState.activeSession }
    public var hostCount: Int { uiState.hostCount }
    public var hasConfiguredHosts: Bool { uiState.hostCount > 0 }
    public var hasOpenClawForActiveSession: Bool {
        guard let activeSession else { return false }
        return uiState.openClawHostIDs.contains(activeSession.hostID)
    }
    public var shouldOfferHostCreation: Bool {
        if case .loaded = uiState.state {
            return uiState.hostCount == 0
        }
        return false
    }

    private let loadHomeStatus: LoadHomeStatus
    private let loadActiveSession: LoadActiveConnectionSession?
    private let loadHosts: LoadHosts?

    public init(
        loadHomeStatus: LoadHomeStatus,
        loadActiveSession: LoadActiveConnectionSession? = nil,
        loadHosts: LoadHosts? = nil
    ) {
        self.loadHomeStatus = loadHomeStatus
        self.loadActiveSession = loadActiveSession
        self.loadHosts = loadHosts
    }

    public func load() async {
        uiState.state = .loading
        do {
            async let status = loadHomeStatus()
            async let session = loadActiveSession?()
            async let hosts = loadHosts?()
            uiState.state = .loaded(try await status)
            uiState.activeSession = await session
            if let hosts = try? await hosts {
                uiState.hostCount = hosts.count
                uiState.openClawHostIDs = Set(
                    hosts
                        .filter { $0.openClawConfiguration != nil }
                        .map(\.id)
                )
            }
        } catch let error as DomainError {
            uiState.state = .failed(error)
            effect = .showError(error.localizedDescription)
        } catch {
            uiState.state = .failed(.unknown)
            effect = .showError(DomainError.unknown.localizedDescription)
        }
    }

    public func clearEffect() {
        effect = .none
    }
}
