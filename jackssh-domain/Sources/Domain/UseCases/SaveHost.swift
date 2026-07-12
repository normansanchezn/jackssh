import Foundation

/// Validates a host draft and persists it. Returns the created/updated `Host`.
/// Throws `DomainError.validation` when the draft is invalid — no partial writes.
public struct SaveHost: Sendable {
    private let repository: HostRepository
    private let secretStore: SecretStore

    public init(repository: HostRepository, secretStore: SecretStore) {
        self.repository = repository
        self.secretStore = secretStore
    }

    public func callAsFunction(
        _ draft: HostDraft,
        id: UUID = UUID(),
        credential: Data? = nil
    ) async throws -> Host {
        let issues = HostValidator.validate(draft)
        guard issues.isEmpty else { throw DomainError.validation(issues) }

        let openClawConfig: OpenClawConfiguration?
        if let host = draft.openClawHost, !host.isEmpty {
            openClawConfig = OpenClawConfiguration(
                host: host,
                port: draft.openClawPort ?? 18789,
                scheme: draft.openClawScheme ?? "http",
                basePath: draft.openClawBasePath ?? "/"
            )
        } else {
            openClawConfig = nil
        }

        let host = Host(
            id: id,
            name: draft.name.trimmingCharacters(in: .whitespacesAndNewlines),
            hostname: draft.hostname.trimmingCharacters(in: .whitespacesAndNewlines),
            port: draft.port,
            username: draft.username.trimmingCharacters(in: .whitespacesAndNewlines),
            authenticationMethod: draft.authenticationMethod,
            openClawConfiguration: openClawConfig,
            favoriteRemotePath: draft.favoriteRemotePath
        )

        // Store credential if provided
        if let credential = credential {
            let credentialKey = SecretKey.password(hostID: id)
            try await secretStore.setSecret(credential, for: credentialKey)
            #if DEBUG
            print("[SaveHost] 📝 Stored credential for host \(id) with key: \(credentialKey)")
            #endif
        } else {
            #if DEBUG
            print("[SaveHost] ⚠️ No credential provided for host \(id)")
            #endif
        }

        try await repository.save(host)
        return host
    }
}
