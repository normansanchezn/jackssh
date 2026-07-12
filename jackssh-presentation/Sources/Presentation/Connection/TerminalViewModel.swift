import Foundation
import Observation
import Domain

/// Screen-level state for the interactive terminal: resolves the host, then
/// builds the `TerminalSession` that owns the live PTY. Holds no terminal
/// buffer of its own — SwiftTerm owns the buffer, the session owns the channel.
@MainActor
@Observable
public final class TerminalViewModel {
    public private(set) var host: Domain.Host?
    public private(set) var session: TerminalSession?
    public private(set) var loadError: String?

    private let hostID: UUID
    private let loadHosts: LoadHosts
    private let openTerminal: OpenTerminal

    public init(hostID: UUID, loadHosts: LoadHosts, openTerminal: OpenTerminal) {
        self.hostID = hostID
        self.loadHosts = loadHosts
        self.openTerminal = openTerminal
    }

    /// Human-readable connection target, e.g. `root@108.174.154.104`.
    public var connectionTitle: String {
        guard let host else { return "Terminal" }
        return "\(host.username)@\(host.hostname)"
    }

    public func load() async {
        do {
            let hosts = try await loadHosts()
            guard let match = hosts.first(where: { $0.id == hostID }) else {
                loadError = "Host not found"
                return
            }
            host = match
            session = TerminalSession(host: match, openTerminal: openTerminal)
        } catch {
            loadError = error.localizedDescription
        }
    }
}
