import Foundation

/// Retrieves a single remote directory through the configured SFTP adapter.
public struct ListRemoteDirectory: Sendable {
    private let repository: RemoteDirectoryRepository

    public init(repository: RemoteDirectoryRepository) {
        self.repository = repository
    }

    public func callAsFunction(at path: String) async throws -> [SFTPFileInfo] {
        try await repository.listDirectory(at: path)
    }
}
