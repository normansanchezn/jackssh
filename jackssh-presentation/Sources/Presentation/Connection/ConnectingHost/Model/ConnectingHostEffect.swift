import Domain

public enum ConnectingHostEffect: Equatable {
    case none
    case connected(ConnectedHostSession)
    case showError(String)
    case cancelled
}
