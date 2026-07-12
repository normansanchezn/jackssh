import Domain

public struct TerminalUIState {
    public var host: Domain.Host?
    public var session: TerminalSession?
    public var loadError: String?

    public init() {}

    public var connectionTitle: String {
        guard let host else { return "Terminal" }
        return "\(host.username)@\(host.hostname)"
    }
}
