//
//  JackSshTests.swift
//  JackSshTests
//
//  Created by Norman Sánchez on 11/07/26.
//

import Testing
import Foundation
import Presentation
@testable import JackSsh

/// App-level integration smoke test: verifies the composition root wires the
/// foundation together and the Home slice loads end to end.
@MainActor
struct JackSshTests {
    @Test func compositionRootBuildsAndHomeLoads() async {
        let composition = CompositionRoot(inMemory: true)

        // Router starts empty; Home view model starts idle.
        #expect(composition.router.path.isEmpty)
        #expect(composition.homeViewModel.state == .idle)

        // Loading drives the state machine into a loaded snapshot.
        await composition.homeViewModel.load()
        guard case .loaded = composition.homeViewModel.state else {
            Issue.record("Expected Home to reach .loaded, got \(composition.homeViewModel.state)")
            return
        }
    }

    @Test func deepLinkNavigatesThroughRouter() {
        let composition = CompositionRoot(inMemory: true)
        let handled = composition.router.handle(url: URL(string: "jackssh://hosts/7")!)
        #expect(handled)
        #expect(composition.router.path == [.host(id: "7")])
    }
}
