import Foundation
import Observation
import Domain

/// Drives the Home screen. Holds no view code and no I/O — it calls the
/// `LoadHomeStatus` use case and exposes a simple, testable state machine.
@MainActor
@Observable
public final class HomeViewModel {
    public enum ViewState: Equatable {
        case idle
        case loading
        case loaded(HomeStatus)
        case failed(DomainError)
    }

    public private(set) var state: ViewState = .idle

    private let loadHomeStatus: LoadHomeStatus

    public init(loadHomeStatus: LoadHomeStatus) {
        self.loadHomeStatus = loadHomeStatus
    }

    public func load() async {
        state = .loading
        do {
            state = .loaded(try await loadHomeStatus())
        } catch let error as DomainError {
            state = .failed(error)
        } catch {
            state = .failed(.unknown)
        }
    }
}
