import Foundation

/// Attempts SSH connection to a host. Updates ConnectionStatusRepository.
/// Returns true if connection succeeded, false otherwise.
public struct AttemptConnection: Sendable {
    private let sshConnector: SSHConnector
    private let statusRepository: ConnectionStatusRepository

    public init(
        sshConnector: SSHConnector,
        statusRepository: ConnectionStatusRepository
    ) {
        self.sshConnector = sshConnector
        self.statusRepository = statusRepository
    }

    public func callAsFunction(to host: Host) async throws -> Bool {
        let startStatus = ConnectionStatus(hostID: host.id, state: .connecting)
        try await statusRepository.setStatus(startStatus)

        let result = await sshConnector.connect(to: host)

        let finalStatus: ConnectionStatus
        switch result {
        case .success:
            finalStatus = ConnectionStatus(hostID: host.id, state: .connected)
        case .authenticationFailed(let error):
            finalStatus = ConnectionStatus(hostID: host.id, state: .authenticationFailed(error))
        case .hostUnreachable(let error):
            finalStatus = ConnectionStatus(hostID: host.id, state: .hostUnreachable(error))
        case .timeout:
            finalStatus = ConnectionStatus(hostID: host.id, state: .timeout)
        case .hostKeyVerificationRequired(let key):
            finalStatus = ConnectionStatus(hostID: host.id, state: .hostKeyVerificationRequired(key))
        case .hostKeyChanged(let message):
            finalStatus = ConnectionStatus(hostID: host.id, state: .hostKeyChanged(message))
        case .failed(let error):
            finalStatus = ConnectionStatus(hostID: host.id, state: .failed(error))
        }

        try await statusRepository.setStatus(finalStatus)
        return result.isSuccess
    }
}

/// Result enum for SSH connection attempts.
public enum SSHConnectionResult: Sendable {
    case success
    case authenticationFailed(String)
    case hostUnreachable(String)
    case timeout
    case hostKeyVerificationRequired(String)
    case hostKeyChanged(String)
    case failed(String)

    public var isSuccess: Bool {
        if case .success = self { return true }
        return false
    }
}

/// Protocol for low-level SSH connection (implemented in Data).
public protocol SSHConnector: Sendable {
    func connect(to host: Host) async -> SSHConnectionResult
}
