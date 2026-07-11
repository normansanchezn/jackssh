import Foundation

/// Returns all managed hosts, sorted by the repository.
public struct LoadHosts: Sendable {
    private let repository: HostRepository

    public init(repository: HostRepository) {
        self.repository = repository
    }

    public func callAsFunction() async throws -> [Host] {
        try await repository.all()
    }
}
