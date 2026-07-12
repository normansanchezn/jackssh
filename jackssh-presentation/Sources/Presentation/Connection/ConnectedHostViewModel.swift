import Foundation
import Observation
import Domain

@MainActor
@Observable
public final class ConnectedHostViewModel {
    public private(set) var session: ConnectedHostSession?
    public private(set) var host: Domain.Host?
    public private(set) var isLoading = true
    public private(set) var loadError: String?

    private let hostID: UUID
    private let loadHost: LoadHosts
    private let loadActiveSession: LoadActiveConnectionSession
    private let endSession: EndConnectionSession

    public init(
        hostID: UUID,
        loadHost: LoadHosts,
        loadActiveSession: LoadActiveConnectionSession,
        endSession: EndConnectionSession
    ) {
        self.hostID = hostID
        self.loadHost = loadHost
        self.loadActiveSession = loadActiveSession
        self.endSession = endSession
    }

    public func load() async {
        do {
            let hosts = try await loadHost()
            host = hosts.first(where: { $0.id == hostID })
            session = await loadActiveSession(for: hostID)
            if host == nil {
                loadError = "Host not found"
            } else if session == nil {
                loadError = "This SSH session is no longer active"
            }
        } catch {
            loadError = error.localizedDescription
        }
        isLoading = false
    }

    public func disconnect() async {
        await endSession(for: hostID)
        session = nil
    }
}
