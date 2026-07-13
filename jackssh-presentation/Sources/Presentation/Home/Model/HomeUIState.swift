import Foundation
import Domain

public struct HomeUIState: Equatable {
    public enum ViewState: Equatable {
        case idle
        case loading
        case loaded(HomeStatus)
        case failed(DomainError)
    }

    public var state: ViewState = .idle
    public var activeSession: ConnectedHostSession?
    public var activeHost: Domain.Host?
    public var hostCount: Int = 0
    public var openClawHostIDs: Set<UUID> = []
    public var openClawLogs: [OpenClawLogEntry] = []
    public var openClawLogsError: String?

    public init() {}
}
