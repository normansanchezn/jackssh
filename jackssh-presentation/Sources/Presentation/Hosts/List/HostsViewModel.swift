import Foundation
import Observation
import Domain

/// Drives the Hosts list. Loads via `LoadHosts`, deletes via `DeleteHost`.
/// Holds no view code and performs no persistence itself.
@MainActor
@Observable
public final class HostsViewModel {
    public typealias ViewState = HostsUIState.ViewState

    public private(set) var uiState = HostsUIState()
    public private(set) var effect: HostsEffect = .none
    public var state: ViewState { uiState.state }
    public var activeSession: ConnectedHostSession? { uiState.activeSession }

    private let loadHosts: LoadHosts
    private let deleteHost: DeleteHost
    private let loadActiveSession: LoadActiveConnectionSession?

    public init(
        loadHosts: LoadHosts,
        deleteHost: DeleteHost,
        loadActiveSession: LoadActiveConnectionSession? = nil
    ) {
        self.loadHosts = loadHosts
        self.deleteHost = deleteHost
        self.loadActiveSession = loadActiveSession
    }

    public var hosts: [Domain.Host] {
        uiState.hosts
    }

    public func load() async {
        uiState.state = .loading
        do {
            uiState.activeSession = await loadActiveSession?()
            uiState.state = .loaded(try await loadHosts())
        } catch let error as DomainError {
            uiState.state = .failed(error)
            effect = .showError(error.localizedDescription)
        } catch {
            uiState.state = .failed(.unknown)
            effect = .showError(DomainError.unknown.localizedDescription)
        }
    }

    public func delete(id: UUID) async {
        do {
            try await deleteHost(id: id)
            effect = .hostDeleted(id)
            await load()
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
