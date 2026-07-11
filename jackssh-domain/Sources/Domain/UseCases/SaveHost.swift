import Foundation

/// Validates a host draft and persists it. Returns the created/updated `Host`.
/// Throws `DomainError.validation` when the draft is invalid — no partial writes.
public struct SaveHost: Sendable {
    private let repository: HostRepository

    public init(repository: HostRepository) {
        self.repository = repository
    }

    public func callAsFunction(_ draft: HostDraft, id: UUID = UUID()) async throws -> Host {
        let issues = HostValidator.validate(draft)
        guard issues.isEmpty else { throw DomainError.validation(issues) }
        let host = Host(
            id: id,
            name: draft.name.trimmingCharacters(in: .whitespacesAndNewlines),
            hostname: draft.hostname.trimmingCharacters(in: .whitespacesAndNewlines),
            port: draft.port,
            username: draft.username.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        try await repository.save(host)
        return host
    }
}
