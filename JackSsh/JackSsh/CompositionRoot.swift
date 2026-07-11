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

    init(inMemory: Bool = false) {
        do {
            modelContainer = try JackSshStore.makeContainer(inMemory: inMemory)
        } catch {
            // Persistence is required to run; fail fast during development.
            fatalError("Failed to build ModelContainer: \(error)")
        }

        router = AppRouter()

        // Home slice: stub repository (no invented backend) → use case → view model.
        let homeRepository: HomeStatusRepository = StubHomeStatusRepository()
        homeViewModel = HomeViewModel(loadHomeStatus: LoadHomeStatus(repository: homeRepository))
    }
}
