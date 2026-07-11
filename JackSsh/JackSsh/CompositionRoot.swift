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
            // Persistence is required to run; fail fast during development.
            fatalError("Failed to build ModelContainer: \(error)")
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
        hostsDependencies = HostsDependencies(
            makeListViewModel: {
                HostsViewModel(
                    loadHosts: LoadHosts(repository: hostRepository),
                    deleteHost: DeleteHost(repository: hostRepository, secrets: secretStore)
                )
            },
            makeEditorViewModel: { existing in
                let saveHost = SaveHost(repository: hostRepository)
                if let existing {
                    return HostEditorViewModel(saveHost: saveHost, host: existing)
                }
                return HostEditorViewModel(saveHost: saveHost)
            }
        )
    }
}
