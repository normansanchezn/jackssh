import Foundation
import Testing
@testable import Data
import Domain

@Suite("InMemoryConnectionSessionStore")
struct ConnectionSessionStoreTests {
    @Test("Tracks, replaces, and clears a session by host")
    func tracksSessionLifecycle() async {
        let store = InMemoryConnectionSessionStore()
        let hostID = UUID()
        let initial = ConnectedHostSession(
            hostID: hostID,
            hostname: "host.example",
            username: "root",
            port: 22
        )

        await store.activate(initial)
        #expect(await store.activeSession(for: hostID) == initial)
        #expect(await store.mostRecentActiveSession() == initial)

        await store.deactivate(hostID: hostID)
        #expect(await store.activeSession(for: hostID) == nil)
        #expect(await store.mostRecentActiveSession() == nil)
    }
}
