import Foundation
import Domain

/// SSH connection stub (real implementation via Citadel to be completed).
public actor CitadelSSHConnector: SSHConnector {
    private let credentialStore: CredentialStore

    public init(credentialStore: CredentialStore) {
        self.credentialStore = credentialStore
    }

    public func connect(to host: Domain.Host) async -> SSHConnectionResult {
        do {
            switch host.authenticationMethod {
            case .password:
                guard let _ = try await credentialStore.password(for: host.id) else {
                    return .authenticationFailed("Password not found in Keychain")
                }
            case .publicKey:
                guard let _ = try await credentialStore.privateKey(for: host.id) else {
                    return .authenticationFailed("SSH key not found in Keychain")
                }
            }
            return .success
        } catch {
            return .failed(error.localizedDescription)
        }
    }
}
