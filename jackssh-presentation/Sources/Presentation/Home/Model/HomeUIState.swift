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

    public init() {}
}
