import Foundation

/// State machine for SSH host connection flow.
public enum HostConnectionState: Equatable, Sendable {
    case idle
    case resolving
    case verifyingHostKey(fingerprint: String?)
    case awaitingHostTrust(fingerprint: String)
    case authenticating
    case openingSession
    case preparingWorkspace
    case connected(ConnectedHostSession)
    case failed(HostConnectionFailure)
    case cancelled
}

/// Failed connection reason and optional recovery action.
public struct HostConnectionFailure: Equatable, Sendable {
    public enum Kind: Equatable, Sendable {
        case hostUnreachable(String)
        case authenticationFailed(String)
        case hostKeyChanged(String)
        case timeout
        case invalidConfiguration(String)
        case missingCredentials(String)
        case other(String)
    }

    public let kind: Kind
    public let canRetry: Bool

    public init(kind: Kind, canRetry: Bool = true) {
        self.kind = kind
        self.canRetry = canRetry
    }

    public var description: String {
        switch kind {
        case let .hostUnreachable(msg): return msg
        case let .authenticationFailed(msg): return msg
        case let .hostKeyChanged(msg): return msg
        case .timeout: return "Connection timed out"
        case let .invalidConfiguration(msg): return msg
        case let .missingCredentials(msg): return msg
        case let .other(msg): return msg
        }
    }
}

/// Active SSH session for a host.
public struct ConnectedHostSession: Equatable, Sendable {
    public let hostID: UUID
    public let hostname: String
    public let username: String
    public let port: Int
    public let connectedAt: Date
    public let sessionID: UUID

    public init(
        hostID: UUID,
        hostname: String,
        username: String,
        port: Int,
        connectedAt: Date = Date(),
        sessionID: UUID = UUID()
    ) {
        self.hostID = hostID
        self.hostname = hostname
        self.username = username
        self.port = port
        self.connectedAt = connectedAt
        self.sessionID = sessionID
    }
}
