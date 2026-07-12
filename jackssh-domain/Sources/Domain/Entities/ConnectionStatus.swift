import Foundation

/// Ephemeral SSH connection state.
public enum ConnectionState: Equatable, Sendable {
    case idle
    case connecting
    case connected
    case authenticationFailed(String)
    case hostUnreachable(String)
    case timeout
    case hostKeyVerificationRequired(String)
    case hostKeyChanged(String)
    case failed(String)
}

/// Snapshot of connection state for a host.
public struct ConnectionStatus: Equatable, Sendable {
    public let hostID: UUID
    public let state: ConnectionState
    public let timestamp: Date

    public init(hostID: UUID, state: ConnectionState, timestamp: Date = Date()) {
        self.hostID = hostID
        self.state = state
        self.timestamp = timestamp
    }
}
