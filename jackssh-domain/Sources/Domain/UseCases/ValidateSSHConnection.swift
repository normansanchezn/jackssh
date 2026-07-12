import Foundation

/// Validates SSH connection before saving host configuration.
/// Throws if connection fails, returns success message if reachable.
public struct ValidateSSHConnection: Sendable {
    private let sshConnector: SSHConnector

    public init(sshConnector: SSHConnector) {
        self.sshConnector = sshConnector
    }

    public func callAsFunction(for host: Host) async throws {
        let result = await sshConnector.connect(to: host)

        switch result {
        case .success:
            return
        case .authenticationFailed(let error):
            throw DomainError.validation([
                .init(field: .authenticationMethod, message: "Authentication failed: \(error)")
            ])
        case .hostUnreachable(let error):
            throw DomainError.validation([
                .init(field: .hostname, message: "Host unreachable: \(error)")
            ])
        case .timeout:
            throw DomainError.validation([
                .init(field: .hostname, message: "Connection timeout.")
            ])
        case .hostKeyVerificationRequired(let key):
            throw DomainError.validation([
                .init(field: .hostname, message: "Host key verification required: \(key)")
            ])
        case .hostKeyChanged(let message):
            throw DomainError.validation([
                .init(field: .hostname, message: "WARNING: Host key changed! \(message)")
            ])
        case .failed(let error):
            throw DomainError.validation([
                .init(field: .hostname, message: "Connection failed: \(error)")
            ])
        }
    }
}
