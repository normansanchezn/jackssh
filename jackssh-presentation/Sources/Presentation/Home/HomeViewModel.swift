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
    public private(set) var activeSession: ConnectedHostSession?

    private let loadHomeStatus: LoadHomeStatus
    private let loadActiveSession: LoadActiveConnectionSession?

    public init(
        loadHomeStatus: LoadHomeStatus,
        loadActiveSession: LoadActiveConnectionSession? = nil
    ) {
        self.loadHomeStatus = loadHomeStatus
        self.loadActiveSession = loadActiveSession
    }

    public func load() async {
        state = .loading
        do {
            async let status = loadHomeStatus()
            async let session = loadActiveSession?()
            state = .loaded(try await status)
            activeSession = await session
        } catch let error as DomainError {
            state = .failed(error)
        } catch {
            state = .failed(.unknown)
        }
    }
}
