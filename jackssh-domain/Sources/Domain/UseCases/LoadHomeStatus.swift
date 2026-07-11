import Foundation

/// Loads the aggregated Home snapshot. Thin use case over `HomeStatusRepository`;
/// exists so Presentation depends on an intent, not a repository directly.
public struct LoadHomeStatus: Sendable {
    private let repository: HomeStatusRepository

    public init(repository: HomeStatusRepository) {
        self.repository = repository
    }

    public func callAsFunction() async throws -> HomeStatus {
        try await repository.currentStatus()
    }
}
