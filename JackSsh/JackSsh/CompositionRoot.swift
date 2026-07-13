//
//  CompositionRoot.swift
//  JackSsh
//
//  Composition root: the ONLY place that knows about concrete implementations.
//  It wires Data implementations into Domain use cases and hands finished
//  objects to Presentation. Keeps the app target thin — no business logic here.
//

import Foundation
import SwiftData
import Domain
import Data
import Presentation
import Shared

@MainActor
final class CompositionRoot {
    let router: AppRouter

    let modelContainer: ModelContainer
    private let authRepository: SupabaseAuthRepository
    private let biometricLoginRepository: BiometricLoginRepository
    private let hostRepository: HostRepository
    private let secretStore: SecretStore
    private let homeStatusRepository: HomeStatusRepository
    private let sshConnector: SSHConnector
    private let terminalConnecting: TerminalConnecting
    private let portForwarding: PortForwarding
    private let openClawAuthenticator: OpenClawAuthenticating
    private let openClawLogRepository: OpenClawLogRepository
    private let sessionStore: ConnectionSessionStore
    private let portForwardLifecycleReporter = SystemPortForwardLifecycleReporter()
    private let portForwardSessionRegistry = PortForwardSessionRegistry()

    private(set) lazy var authViewModel: AuthViewModel = {
        AuthViewModel(
            signIn: SignIn(repository: authRepository),
            signUp: SignUp(repository: authRepository),
            signOut: SignOut(repository: authRepository),
            loadCurrentUser: LoadCurrentUser(repository: authRepository),
            loadBiometricLoginAvailability: LoadBiometricLoginAvailability(repository: biometricLoginRepository),
            enableBiometricLogin: EnableBiometricLogin(repository: biometricLoginRepository),
            loadBiometricLoginCredentials: LoadBiometricLoginCredentials(repository: biometricLoginRepository)
        )
    }()

    private(set) lazy var homeViewModel: HomeViewModel = {
        HomeViewModel(
            loadHomeStatus: LoadHomeStatus(repository: homeStatusRepository),
            loadActiveSession: LoadActiveConnectionSession(store: sessionStore),
            loadHosts: LoadHosts(repository: hostRepository),
            loadOpenClawLogs: LoadOpenClawLogs(repository: openClawLogRepository)
        )
    }()

    private(set) lazy var hostsDependencies: HostsDependencies = {
        makeHostsDependencies()
    }()

    init(inMemory: Bool = false) {
        do {
            modelContainer = try JackSshStore.makeContainer(inMemory: inMemory)
        } catch {
            #if DEBUG
            do {
                modelContainer = try JackSshStore.makeContainer(inMemory: true)
            } catch {
                fatalError("Failed to build ModelContainer (both persistent and in-memory): \(error)")
            }
            #else
            fatalError("Failed to build ModelContainer: \(error)")
            #endif
        }

        let supabaseService = SupabaseAuthService(
            supabaseURL: EnvironmentConfig.supabaseURL,
            supabaseKey: EnvironmentConfig.supabaseKey
        )
        secretStore = KeychainSecretStore()
        let supabaseAuthRepository = SupabaseAuthRepository(service: supabaseService, secureStore: secretStore)
        authRepository = supabaseAuthRepository
        biometricLoginRepository = BiometricKeychainLoginRepository()

        let localHostRepository = SwiftDataHostRepository(modelContainer: modelContainer)
        let remoteHostRepository = SupabaseHostRepository(
            supabaseURL: EnvironmentConfig.supabaseURL,
            supabaseKey: EnvironmentConfig.supabaseKey,
            sessionProvider: supabaseAuthRepository
        )
        hostRepository = SyncingHostRepository(local: localHostRepository, remote: remoteHostRepository)
        homeStatusRepository = HealthProbingHomeStatusRepository(
            configuration: .unconfigured,
            http: URLSessionHealthProbe(),
            ssh: CitadelSSHHealthProbe(sessionProvider: { _ in nil })
        )
        sshConnector = CitadelSSHConnector(credentialStore: secretStore)
        terminalConnecting = CitadelTerminalConnecting(secretStore: secretStore)
        portForwarding = CitadelPortForwarding(secretStore: secretStore)
        openClawAuthenticator = CitadelOpenClawAuthenticator(secretStore: secretStore)
        openClawLogRepository = CitadelOpenClawLogRepository(secretStore: secretStore)
        sessionStore = InMemoryConnectionSessionStore()
        router = AppRouter()
    }

    // MARK: - Factories

    private func makeHostsDependencies() -> HostsDependencies {
        HostsDependencies(
            makeListViewModel: { [self] in
                HostsViewModel(
                    loadHosts: LoadHosts(repository: hostRepository),
                    deleteHost: DeleteHost(repository: hostRepository, secrets: secretStore)
                )
            },
            makeEditorViewModel: { [self] existing in
                let saveHost = SaveHost(repository: hostRepository, secretStore: secretStore)
                return existing.map { HostEditorViewModel(saveHost: saveHost, host: $0) }
                    ?? HostEditorViewModel(saveHost: saveHost)
            },
            makeConnectingViewModel: { [self] hostID in
                ConnectingHostViewModel(
                    hostID: hostID,
                    loadHost: LoadHosts(repository: hostRepository),
                    connectToHost: ConnectToHost(connector: sshConnector),
                    activateSession: ActivateConnectionSession(store: sessionStore)
                )
            },
            makeConnectedViewModel: { [self] hostID in
                ConnectedHostViewModel(
                    hostID: hostID,
                    loadHost: LoadHosts(repository: hostRepository),
                    loadActiveSession: LoadActiveConnectionSession(store: sessionStore),
                    endSession: EndConnectionSession(store: sessionStore)
                )
            },
            makeTerminalViewModel: { [self] hostID in
                TerminalViewModel(
                    hostID: hostID,
                    loadHosts: LoadHosts(repository: hostRepository),
                    openTerminal: OpenTerminal(connecting: terminalConnecting),
                    activateSession: ActivateConnectionSession(store: sessionStore),
                    endSession: EndConnectionSession(store: sessionStore)
                )
            },
            makeRemoteFilesViewModel: { [self] hostID, path in
                RemoteFilesViewModel(
                    hostID: hostID,
                    initialPath: path,
                    loadHosts: LoadHosts(repository: hostRepository),
                    makeDirectoryRepository: { host in
                        CitadelRemoteDirectoryRepository(host: host, secretStore: self.secretStore)
                    },
                    makeFileRepository: { host in
                        CitadelRemoteDirectoryRepository(host: host, secretStore: self.secretStore)
                    }
                )
            },
            makeOpenClawDashboardViewModel: { [self] hostID in
                OpenClawDashboardViewModel(
                    hostID: hostID,
                    loadHosts: LoadHosts(repository: hostRepository),
                    openPortForward: OpenPortForward(forwarding: portForwarding),
                    resolveAuthToken: ResolveOpenClawAuthToken(authenticator: openClawAuthenticator),
                    portForwardLifecycleReporter: portForwardLifecycleReporter,
                    sessionRegistry: portForwardSessionRegistry
                )
            }
        )
    }
}
