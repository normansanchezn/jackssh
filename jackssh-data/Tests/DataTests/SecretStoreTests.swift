import Testing
import Foundation
import Domain
@testable import Data

@Suite("InMemorySecretStore")
struct SecretStoreTests {
    @Test func roundTripsSecret() async throws {
        let store = InMemorySecretStore()
        let value = Data("private-key".utf8)
        try await store.setSecret(value, for: "host-1")
        #expect(try await store.secret(for: "host-1") == value)
    }

    @Test func returnsNilForMissingKey() async throws {
        let store = InMemorySecretStore()
        #expect(try await store.secret(for: "absent") == nil)
    }

    @Test func removesSecret() async throws {
        let store = InMemorySecretStore(seed: ["k": Data("v".utf8)])
        try await store.removeSecret(for: "k")
        #expect(try await store.secret(for: "k") == nil)
    }
}
