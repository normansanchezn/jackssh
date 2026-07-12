import Domain

public struct ConnectedHostUIState: Equatable {
    public var session: ConnectedHostSession?
    public var host: Domain.Host?
    public var isLoading = true
    public var loadError: String?

    public init() {}
}
