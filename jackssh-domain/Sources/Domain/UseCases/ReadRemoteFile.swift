import Foundation

/// Retrieves the bytes of one existing remote file for read-only inspection.
public struct ReadRemoteFile: Sendable {
    private let repository: RemoteFileRepository

    public init(repository: RemoteFileRepository) {
        self.repository = repository
    }

    public func callAsFunction(at path: String) async throws -> Data {
        try await repository.readFile(at: path)
    }
}
