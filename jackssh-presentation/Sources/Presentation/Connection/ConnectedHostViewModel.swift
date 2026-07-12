import Foundation
import Observation
import Domain

@MainActor
@Observable
public final class ConnectedHostViewModel {
    public private(set) var session: ConnectedHostSession?
    public private(set) var host: Domain.Host?
    public private(set) var isLoading = true

    private let hostID: UUID
    private let loadHost: LoadHosts

    public init(hostID: UUID, loadHost: LoadHosts) {
        self.hostID = hostID
        self.loadHost = loadHost
    }

    public func load() async {
        do {
            let hosts = try await loadHost()
            host = hosts.first(where: { $0.id == hostID })
            if let host = host {
                session = ConnectedHostSession(
                    hostID: host.id,
                    hostname: host.hostname,
                    username: host.username,
                    port: host.port
                )
            }
        } catch {
            // Handle error
        }
        isLoading = false
    }
}
