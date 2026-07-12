import Domain

public struct ConnectingHostUIState: Equatable {
    public var state: HostConnectionState = .idle
    public var host: Domain.Host?
    public var error: String?

    public init() {}
}
