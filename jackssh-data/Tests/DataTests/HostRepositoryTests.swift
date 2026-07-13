import Testing
import Foundation
import SwiftData
import Domain
@testable import Data

@Suite("SwiftData HostRepository")
struct HostRepositoryTests {
    private func makeRepository() throws -> SwiftDataHostRepository {
        let container = try JackSshStore.makeContainer(inMemory: true)
        return SwiftDataHostRepository(modelContainer: container)
    }

    @Test func savesAndFetchesHost() async throws {
        let repo = try makeRepository()
        let host = Domain.Host(name: "VPS", hostname: "vps.example", username: "root")
        try await repo.save(host)

        let all = try await repo.all()
        #expect(all.count == 1)
        #expect(all.first?.hostname == "vps.example")
    }

    @Test func updatesExistingHostInPlace() async throws {
        let repo = try makeRepository()
        var host = Domain.Host(name: "VPS", hostname: "old.example", username: "root")
        try await repo.save(host)
        host.hostname = "new.example"
        try await repo.save(host)

        let all = try await repo.all()
        #expect(all.count == 1)
        #expect(all.first?.hostname == "new.example")
    }

    @Test func deletesHost() async throws {
        let repo = try makeRepository()
        let host = Domain.Host(name: "VPS", hostname: "vps.example", username: "root")
        try await repo.save(host)
        try await repo.delete(id: host.id)
        #expect(try await repo.all().isEmpty)
    }

    @Test func persistsMultipleFavoriteRemotePaths() async throws {
        let repo = try makeRepository()
        let host = Domain.Host(
            name: "VPS",
            hostname: "vps.example",
            username: "root",
            favoriteRemotePaths: ["/var/www", "/etc/nginx", "/srv/openclaw"]
        )

        try await repo.save(host)

        let saved = try #require(await repo.host(id: host.id))
        #expect(saved.primaryFavoriteRemotePath == "/var/www")
        #expect(saved.favoriteRemotePaths == ["/var/www", "/etc/nginx", "/srv/openclaw"])
    }
}
