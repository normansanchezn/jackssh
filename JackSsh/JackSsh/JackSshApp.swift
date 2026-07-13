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
                authViewModel: composition.authViewModel,
                router: composition.router,
                homeViewModel: composition.homeViewModel,
                hostsDependencies: composition.hostsDependencies
            )
                // Deep links are navigational only — never destructive.
                .onOpenURL { url in
                    if !composition.handleActionURL(url) {
                        composition.router.handle(url: url)
                    }
                }
        }
        .modelContainer(composition.modelContainer)
    }
}
