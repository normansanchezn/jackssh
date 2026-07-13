import Foundation

public struct LoadOpenClawLogs: Sendable {
    private let repository: OpenClawLogRepository

    public init(repository: OpenClawLogRepository) {
        self.repository = repository
    }

    public func callAsFunction(for host: Host, limit: Int = 100) async throws -> [OpenClawLogEntry] {
        try await repository.recentLogs(for: host, limit: limit)
    }
}
