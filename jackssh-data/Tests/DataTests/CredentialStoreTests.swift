import Testing
import Foundation
@testable import Data

@Suite("KeychainCredentialStoreTests")
struct KeychainCredentialStoreTests {
    @Test("Store and retrieve password")
    func storeRetrievePassword() async throws {
        let store = KeychainCredentialStore()
        let hostID = UUID()
        let password = "secret123"

        try await store.storePassword(password, for: hostID)
        let retrieved = try await store.password(for: hostID)

        #expect(retrieved == password)
    }

    @Test("Delete credentials removes stored value")
    func deleteCredentials() async throws {
        let store = KeychainCredentialStore()
        let hostID = UUID()

        try await store.storePassword("secret", for: hostID)
        try await store.deleteCredentials(for: hostID)
        let retrieved = try await store.password(for: hostID)

        #expect(retrieved == nil)
    }
}
