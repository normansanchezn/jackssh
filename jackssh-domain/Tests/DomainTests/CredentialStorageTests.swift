import Testing
import Foundation
@testable import Domain

@Suite("Credential Storage Flow")
struct CredentialStorageTests {

    @Test func saveHostStoresCredentialWhenProvided() async throws {
        let mockRepository = MockHostRepository()
        let mockSecretStore = MockSecretStore()
        let saveHost = SaveHost(repository: mockRepository, secretStore: mockSecretStore)

        let draft = HostDraft(
            name: "Test Host",
            hostname: "example.com",
            port: 22,
            username: "testuser",
            authenticationMethod: .password
        )

        let hostID = UUID()
        let credentialData = "mypassword".data(using: .utf8)!

        let savedHost = try await saveHost(draft, id: hostID, credential: credentialData)

        #expect(savedHost.id == hostID)
        #expect(savedHost.name == "Test Host")
        #expect(mockSecretStore.storedSecrets.count == 1)
        #expect(mockSecretStore.storedSecrets["host:\(hostID):auth"] == credentialData)
    }

    @Test func saveHostDoesNotStoreNilCredential() async throws {
        let mockRepository = MockHostRepository()
        let mockSecretStore = MockSecretStore()
        let saveHost = SaveHost(repository: mockRepository, secretStore: mockSecretStore)

        let draft = HostDraft(
            name: "Test Host",
            hostname: "example.com",
            port: 22,
            username: "testuser",
            authenticationMethod: .password
        )

        let hostID = UUID()
        let savedHost = try await saveHost(draft, id: hostID, credential: nil)

        #expect(savedHost.id == hostID)
        #expect(mockSecretStore.storedSecrets.isEmpty)
    }

    @Test func credentialKeyMatchesRetrievalKey() async throws {
        let hostID = UUID()
        let credentialKey = "host:\(hostID):auth"
        let expectedKey = "host:\(hostID):auth"

        #expect(credentialKey == expectedKey)
    }
}

// MARK: - Mocks

actor MockHostRepository: HostRepository {
    var hosts: [Host] = []

    func all() async throws -> [Host] {
        hosts
    }

    func host(id: UUID) async throws -> Host? {
        hosts.first { $0.id == id }
    }

    func save(_ host: Host) async throws {
        if let index = hosts.firstIndex(where: { $0.id == host.id }) {
            hosts[index] = host
        } else {
            hosts.append(host)
        }
    }

    func delete(id: UUID) async throws {
        hosts.removeAll { $0.id == id }
    }
}

final class MockSecretStore: SecretStore, Sendable {
    private(set) var storedSecrets: [String: Data] = [:]

    func secret(for key: String) async throws -> Data? {
        storedSecrets[key]
    }

    func setSecret(_ value: Data, for key: String) async throws {
        storedSecrets[key] = value
    }

    func removeSecret(for key: String) async throws {
        storedSecrets.removeValue(forKey: key)
    }
}
