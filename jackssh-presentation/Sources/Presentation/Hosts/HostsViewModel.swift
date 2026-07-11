import Foundation
import Observation
import Domain

/// Drives the Hosts list. Loads via `LoadHosts`, deletes via `DeleteHost`.
/// Holds no view code and performs no persistence itself.
@MainActor
@Observable
public final class HostsViewModel {
    public enum ViewState: Equatable {
        case idle
        case loading
        case loaded([Domain.Host])
        case failed(DomainError)
    }

    public private(set) var state: ViewState = .idle

    private let loadHosts: LoadHosts
    private let deleteHost: DeleteHost

    public init(loadHosts: LoadHosts, deleteHost: DeleteHost) {
        self.loadHosts = loadHosts
        self.deleteHost = deleteHost
    }

    public var hosts: [Domain.Host] {
        if case let .loaded(hosts) = state { return hosts }
        return []
    }

    public func load() async {
        state = .loading
        do {
            state = .loaded(try await loadHosts())
        } catch let error as DomainError {
            state = .failed(error)
        } catch {
            state = .failed(.unknown)
        }
    }

    public func delete(id: UUID) async {
        do {
            try await deleteHost(id: id)
            await load()
        } catch let error as DomainError {
            state = .failed(error)
        } catch {
            state = .failed(.unknown)
        }
    }
}
