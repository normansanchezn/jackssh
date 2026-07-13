import Foundation
import Citadel
import Domain

/// Verifies a password-based SSH connection through Citadel.
public actor CitadelSSHConnector: SSHConnector {
    private let secretStore: SecretStore

    public init(credentialStore: SecretStore) {
        self.secretStore = credentialStore
    }

    public func connect(to host: Domain.Host) async -> SSHConnectionResult {
        do {
            #if DEBUG
            print("[CitadelSSHConnector] 🔗 Attempting connection to: \(host.hostname):\(host.port)")
            print("[CitadelSSHConnector] 👤 Username: \(host.username)")
            print("[CitadelSSHConnector] 🔐 Auth method: \(host.authenticationMethod)")
            #endif

            let credentialKey: String
            switch host.authenticationMethod {
            case .password:
                credentialKey = SecretKey.password(hostID: host.id)
                #if DEBUG
                print("[CitadelSSHConnector] 🔑 Looking for password with key: \(credentialKey)")
                #endif
                guard let credential = try await secretStore.secret(for: credentialKey),
                      let password = String(data: credential, encoding: .utf8) else {
                    #if DEBUG
                    print("[CitadelSSHConnector] ❌ Password NOT found in Keychain for key: \(credentialKey)")
                    #endif
                    return .authenticationFailed("Password not found in Keychain")
                }
                let client = try await SSHClient.connect(
                    host: host.hostname,
                    port: host.port,
                    authenticationMethod: .passwordBased(username: host.username, password: password),
                    hostKeyValidator: .acceptAnything(),
                    reconnect: .never,
                    connectTimeout: .seconds(15)
                )
                do {
                    _ = try await client.executeCommand("true", maxResponseSize: 1024)
                    try await client.close()
                } catch {
                    try? await client.close()
                    throw error
                }
                return .success

            case .publicKey:
                credentialKey = SecretKey.privateKey(hostID: host.id)
                #if DEBUG
                print("[CitadelSSHConnector] 🔑 Looking for private key with key: \(credentialKey)")
                #endif
                guard let _ = try await secretStore.secret(for: credentialKey) else {
                    #if DEBUG
                    print("[CitadelSSHConnector] ❌ Private key NOT found in Keychain")
                    #endif
                    return .authenticationFailed("SSH key not found in Keychain")
                }
                return .failed("Public-key verification is not implemented yet")
            }
        } catch {
            #if DEBUG
            print("[CitadelSSHConnector] 💥 Connection error: \(error.localizedDescription)")
            #endif
            return .failed(error.localizedDescription)
        }
    }
}
