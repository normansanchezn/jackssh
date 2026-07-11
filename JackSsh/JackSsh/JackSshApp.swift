//
//  JackSshApp.swift
//  JackSsh
//
//  Created by Norman Sánchez on 11/07/26.
//

import SwiftUI
import SwiftData
import Presentation

@main
struct JackSshApp: App {
    @State private var composition = CompositionRoot()

    var body: some Scene {
        WindowGroup {
            RootView(
                router: composition.router,
                homeViewModel: composition.homeViewModel,
                hostsDependencies: composition.hostsDependencies
            )
                // Deep links are navigational only — never destructive.
                .onOpenURL { composition.router.handle(url: $0) }
        }
        .modelContainer(composition.modelContainer)
    }
}
