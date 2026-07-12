import Foundation
import Domain
import Citadel

/// SSH connection via Citadel library.
public actor CitadelSSHConnector: SSHConnector {
    private let credentialStore: CredentialStore
    private let connectionTimeout: TimeInterval = 10

    public init(credentialStore: CredentialStore) {
        self.credentialStore = credentialStore
    }

    public func connect(to host: Host) async -> SSHConnectionResult {
        do {
            let credential: SSHClientCredential

            switch host.authenticationMethod {
            case .password:
                guard let pwd = try await credentialStore.password(for: host.id) else {
                    return .authenticationFailed("Password not found in Keychain")
                }
                credential = SSHClientCredential.password(pwd)
            case .publicKey(let keyID):
                guard let keyData = try await credentialStore.privateKey(for: host.id) else {
                    return .authenticationFailed("SSH key not found in Keychain")
                }
                credential = SSHClientCredential.privateKey(keyData)
            }

            let connection = try await withTimeout(
                timeInterval: connectionTimeout,
                block: {
                    try await SSHClient.connect(
                        host: host.hostname,
                        port: UInt16(host.port),
                        username: host.username,
                        credential: credential
                    )
                }
            )

            defer { try? connection.close() }
            try await connection.executeCommand("echo 'SSH connection successful'")

            return .success

        } catch let error as SSHError {
            return mapSSHError(error)
        } catch {
            if String(describing: error).contains("timeout") {
                return .timeout
            }
            return .failed(error.localizedDescription)
        }
    }

    private func mapSSHError(_ error: SSHError) -> SSHConnectionResult {
        let description = String(describing: error)

        if description.contains("authentication") || description.contains("Authentication") {
            return .authenticationFailed("SSH authentication failed")
        } else if description.contains("host") || description.contains("resolve") {
            return .hostUnreachable("Unable to reach host")
        } else if description.contains("timeout") || description.contains("Timeout") {
            return .timeout
        } else {
            return .failed(description)
        }
    }

    private func withTimeout<T>(
        timeInterval: TimeInterval,
        block: @escaping () async throws -> T
    ) async throws -> T {
        return try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                try await block()
            }

            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(timeInterval * 1_000_000_000))
                throw CancellationError()
            }

            do {
                return try await group.nextResult()!.get()
            } catch {
                group.cancelAll()
                throw error
            }
        }
    }
}
