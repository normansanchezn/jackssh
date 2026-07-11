import Testing
import Foundation
import Domain
import Shared
@testable import Data

@Suite("StubHomeStatusRepository")
struct StubHomeStatusRepositoryTests {
    @Test func returnsDeterministicSnapshot() async throws {
        let fixed = Date(timeIntervalSince1970: 1_000)
        let repo = StubHomeStatusRepository(dates: FixedDateProvider(fixed))
        let status = try await repo.currentStatus()

        #expect(status.privateNetworkOnline)
        #expect(status.recentActivity.first?.timestamp == fixed)
        #expect(status.recentActivity.first?.state == .online)
    }
}
