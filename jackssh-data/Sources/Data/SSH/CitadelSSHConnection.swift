import Foundation
import Domain

/// SSH connection stub (real implementation via Citadel to be completed).
public actor CitadelSSHConnector: SSHConnector {
    private let secretStore: SecretStore

    public init(credentialStore: SecretStore) {
        self.secretStore = credentialStore
    }

    public func connect(to host: Domain.Host) async -> SSHConnectionResult {
        do {
            let credentialKey: String
            switch host.authenticationMethod {
            case .password:
                credentialKey = "host:\(host.id):password"
                guard let _ = try await secretStore.secret(for: credentialKey) else {
                    return .authenticationFailed("Password not found in Keychain")
                }
            case .publicKey:
                credentialKey = "host:\(host.id):privateKey"
                guard let _ = try await secretStore.secret(for: credentialKey) else {
                    return .authenticationFailed("SSH key not found in Keychain")
                }
            }
            // Stub: simulate successful connection after brief delay
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5s
            return .success
        } catch {
            return .failed(error.localizedDescription)
        }
    }
}
