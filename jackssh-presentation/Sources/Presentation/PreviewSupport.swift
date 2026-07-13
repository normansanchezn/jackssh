#if DEBUG
import Foundation
import Domain

@MainActor
enum PreviewFixtures {
    static let host = Host(
        name: "Production VPS",
        hostname: "vps.example.com",
        port: 22,
        username: "deploy",
        tags: ["production"],
        openClawConfiguration: OpenClawConfiguration(host: "127.0.0.1", port: 18789),
        favoriteRemotePath: "/var/www",
        lastSuccessfulConnection: Date().addingTimeInterval(-3_600),
        isFavorite: true
    )

    static let secondaryHost = Host(
        name: "Staging",
        hostname: "staging.example.com",
        port: 2222,
        username: "ubuntu",
        lastSuccessfulConnection: Date().addingTimeInterval(-86_400)
    )

    static func hostsDependencies() -> HostsDependencies {
        HostsDependencies(
            makeListViewModel: {
                let repository = PreviewHostRepository(hosts: [host, secondaryHost])
                return HostsViewModel(
                    loadHosts: LoadHosts(repository: repository),
                    deleteHost: DeleteHost(repository: repository, secrets: PreviewSecretStore())
                )
            },
            makeEditorViewModel: { existing in
                let repository = PreviewHostRepository(hosts: [host, secondaryHost])
                let save = SaveHost(repository: repository, secretStore: PreviewSecretStore())
                return existing.map { HostEditorViewModel(saveHost: save, host: $0) }
                    ?? HostEditorViewModel(saveHost: save)
            },
            makeConnectingViewModel: { hostID in
                let repository = PreviewHostRepository(hosts: [host, secondaryHost])
                return ConnectingHostViewModel(
                    hostID: hostID,
                    loadHost: LoadHosts(repository: repository),
                    connectToHost: ConnectToHost(connector: PreviewSSHConnector()),
                    activateSession: ActivateConnectionSession(store: PreviewSessionStore())
                )
            },
            makeConnectedViewModel: { hostID in
                let repository = PreviewHostRepository(hosts: [host, secondaryHost])
                let store = PreviewSessionStore(session: ConnectedHostSession(
                    hostID: hostID, hostname: host.hostname, username: host.username, port: host.port
                ))
                return ConnectedHostViewModel(
                    hostID: hostID,
                    loadHost: LoadHosts(repository: repository),
                    loadActiveSession: LoadActiveConnectionSession(store: store),
                    endSession: EndConnectionSession(store: store)
                )
            },
            makeTerminalViewModel: { hostID in
                let repository = PreviewHostRepository(hosts: [host, secondaryHost])
                let store = PreviewSessionStore()
                return TerminalViewModel(
                    hostID: hostID,
                    loadHosts: LoadHosts(repository: repository),
                    openTerminal: OpenTerminal(connecting: PreviewTerminalConnecting()),
                    activateSession: ActivateConnectionSession(store: store),
                    endSession: EndConnectionSession(store: store)
                )
            },
            makeRemoteFilesViewModel: { hostID, path in
                RemoteFilesViewModel(
                    hostID: hostID,
                    initialPath: path,
                    loadHosts: LoadHosts(repository: PreviewHostRepository(hosts: [host, secondaryHost])),
                    makeDirectoryRepository: { _ in PreviewDirectoryRepository() },
                    makeFileRepository: { _ in PreviewDirectoryRepository() }
                )
            },
            makeOpenClawDashboardViewModel: { hostID in
                OpenClawDashboardViewModel(
                    hostID: hostID,
                    loadHosts: LoadHosts(repository: PreviewHostRepository(hosts: [host, secondaryHost])),
                    openPortForward: OpenPortForward(forwarding: PreviewPortForwarding()),
                    resolveAuthToken: ResolveOpenClawAuthToken(authenticator: PreviewOpenClawAuthenticator())
                )
            }
        )
    }

    static func homeViewModel() -> HomeViewModel {
        HomeViewModel(
            loadHomeStatus: LoadHomeStatus(repository: PreviewHomeRepository()),
            loadHosts: LoadHosts(repository: PreviewHostRepository(hosts: [host, secondaryHost]))
        )
    }

    static func authViewModel() -> AuthViewModel {
        let repository = PreviewAuthRepository()
        return AuthViewModel(
            signIn: SignIn(repository: repository),
            signUp: SignUp(repository: repository),
            signOut: SignOut(repository: repository),
            loadCurrentUser: LoadCurrentUser(repository: repository)
        )
    }
}

private actor PreviewHostRepository: HostRepository {
    private var values: [Domain.Host]
    init(hosts: [Domain.Host]) { values = hosts }
    func all() async throws -> [Domain.Host] { values }
    func host(id: UUID) async throws -> Domain.Host? { values.first { $0.id == id } }
    func save(_ host: Domain.Host) async throws { values.append(host) }
    func delete(id: UUID) async throws { values.removeAll { $0.id == id } }
}

private actor PreviewSecretStore: SecretStore {
    func secret(for key: String) async throws -> Data? { nil }
    func setSecret(_ value: Data, for key: String) async throws {}
    func removeSecret(for key: String) async throws {}
}

private struct PreviewHomeRepository: HomeStatusRepository {
    func currentStatus() async throws -> HomeStatus {
        HomeStatus(privateNetworkOnline: true, vps: .online, openClaw: .online, ollama: .unknown, recentActivity: [])
    }
}

private actor PreviewAuthRepository: AuthRepository {
    func signUp(email: String, password: String, displayName: String?) async throws -> User {
        User(id: UUID(), email: email, displayName: displayName)
    }
    func signIn(email: String, password: String) async throws -> User { User(id: UUID(), email: email) }
    func signOut() async throws {}
    func getCurrentUser() async throws -> User? { User(id: UUID(), email: "preview@jackssh.app") }
    func resetPassword(email: String) async throws {}
}

private struct PreviewSSHConnector: SSHConnector {
    func connect(to host: Domain.Host) async -> SSHConnectionResult { .success }
}

private actor PreviewSessionStore: ConnectionSessionStore {
    private var current: ConnectedHostSession?
    init(session: ConnectedHostSession? = nil) { current = session }
    func activeSession(for hostID: UUID) async -> ConnectedHostSession? { current?.hostID == hostID ? current : nil }
    func mostRecentActiveSession() async -> ConnectedHostSession? { current }
    func activate(_ session: ConnectedHostSession) async { current = session }
    func deactivate(hostID: UUID) async { if current?.hostID == hostID { current = nil } }
}

private struct PreviewDirectoryRepository: RemoteDirectoryRepository, RemoteFileRepository {
    func listDirectory(at path: String) async throws -> [SFTPFileInfo] {
        [
            SFTPFileInfo(name: "releases", path: path + "/releases", isDirectory: true),
            SFTPFileInfo(name: "current", path: path + "/current", isDirectory: true),
            SFTPFileInfo(name: "README.md", path: path + "/README.md", isDirectory: false, size: 4_096),
        ]
    }

    func readFile(at path: String) async throws -> Data {
        Data("import Foundation\n\nstruct Preview {\n    let path = \"\(path)\"\n}\n".utf8)
    }
}

private struct PreviewTerminalConnecting: TerminalConnecting {
    func connect(to host: Domain.Host, cols: Int, rows: Int) async throws -> TerminalChannel { throw DomainError.offline }
}

private struct PreviewPortForwarding: PortForwarding {
    func startLocalForward(
        to host: Domain.Host,
        target: PortForwardTarget,
        scheme: String,
        basePath: String
    ) async throws -> PortForwardSession {
        PreviewPortForwardSession(endpoint: PortForwardEndpoint(
            localHost: "127.0.0.1",
            localPort: 18789,
            remoteHost: target.host,
            remotePort: target.port,
            scheme: scheme,
            basePath: basePath
        ))
    }
}

private struct PreviewPortForwardSession: PortForwardSession {
    let endpoint: PortForwardEndpoint
    func stop() async {}
}

private struct PreviewOpenClawAuthenticator: OpenClawAuthenticating {
    func token(for host: Domain.Host, configuration: OpenClawConfiguration) async throws -> String? {
        "preview-openclaw-token"
    }
}
#endif
