//
//  CompositionRoot.swift
//  JackSsh
//
//  Composition root: the ONLY place that knows about concrete implementations.
//  It wires Data implementations into Domain use cases and hands finished
//  objects to Presentation. Keeps the app target thin — no business logic here.
//

import SwiftData
import Domain
import Data
import Presentation

@MainActor
final class CompositionRoot {
    let modelContainer: ModelContainer
    let router: AppRouter
    let homeViewModel: HomeViewModel
    let hostsDependencies: HostsDependencies

    init(inMemory: Bool = false) {
        let container: ModelContainer
        do {
            container = try JackSshStore.makeContainer(inMemory: inMemory)
        } catch {
            // Schema mismatch on device: fall back to in-memory
            #if DEBUG
            do {
                container = try JackSshStore.makeContainer(inMemory: true)
            } catch {
                fatalError("Failed to build ModelContainer (both persistent and in-memory): \(error)")
            }
            #else
            fatalError("Failed to build ModelContainer: \(error)")
            #endif
        }
        modelContainer = container
        router = AppRouter()

        // Shared infrastructure.
        let hostRepository: HostRepository = SwiftDataHostRepository(modelContainer: container)
        let secretStore: SecretStore = KeychainSecretStore()

        // Home slice: real health-probing repository.
        // Probe targets are unconfigured for now — a future Settings + KnownHosts
        // feature will supply private (Tailscale) endpoints, credentials, and
        // trusted host keys. Until then, unconfigured targets honestly report
        // `.unknown` and the SSH probe refuses to connect (never accepts an
        // unverified host key). No endpoints or credentials are invented here.
        let httpProbe = URLSessionHealthProbe()
        let sshProbe = CitadelSSHHealthProbe(sessionProvider: { _ in nil })
        let homeRepository: HomeStatusRepository = HealthProbingHomeStatusRepository(
            configuration: .unconfigured,
            http: httpProbe,
            ssh: sshProbe
        )
        homeViewModel = HomeViewModel(loadHomeStatus: LoadHomeStatus(repository: homeRepository))

        // Hosts slice: factories so views never touch Data or build use cases.
        let sshConnector: SSHConnector = CitadelSSHConnector(credentialStore: secretStore)
        let loadHosts = LoadHosts(repository: hostRepository)

        hostsDependencies = HostsDependencies(
            makeListViewModel: {
                HostsViewModel(
                    loadHosts: loadHosts,
                    deleteHost: DeleteHost(repository: hostRepository, secrets: secretStore)
                )
            },
            makeEditorViewModel: { existing in
                let saveHost = SaveHost(repository: hostRepository, secretStore: secretStore)
                if let existing {
                    return HostEditorViewModel(saveHost: saveHost, host: existing)
                }
                return HostEditorViewModel(saveHost: saveHost)
            },
            makeConnectingViewModel: { hostID in
                ConnectingHostViewModel(
                    hostID: hostID,
                    loadHost: loadHosts,
                    sshConnector: sshConnector
                )
            },
            makeConnectedViewModel: { hostID in
                ConnectedHostViewModel(hostID: hostID, loadHost: loadHosts)
            }
        )
    }
}
