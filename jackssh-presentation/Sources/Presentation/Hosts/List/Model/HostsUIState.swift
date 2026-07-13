import Domain

public struct HostsUIState: Equatable {
    public enum ViewState: Equatable {
        case idle
        case loading
        case loaded([Domain.Host])
        case failed(DomainError)
    }

    public var state: ViewState = .idle
    public var activeSession: ConnectedHostSession?

    public var hosts: [Domain.Host] {
        if case let .loaded(hosts) = state { return hosts }
        return []
    }

    public init() {}
}
