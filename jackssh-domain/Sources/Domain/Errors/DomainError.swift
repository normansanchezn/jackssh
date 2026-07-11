import Foundation

/// Stable, presentation-agnostic error taxonomy. Data maps infrastructure errors into these.
public enum DomainError: Error, Equatable, Sendable {
    case offline
    case unreachable
    case unauthorized
    case notFound
    case validation([ValidationIssue])
    case hostKeyChanged
    case timeout
    case unknown

    public var isRecoverable: Bool {
        switch self {
        case .offline, .unreachable, .timeout: return true
        case .unauthorized, .notFound, .validation, .hostKeyChanged, .unknown: return false
        }
    }
}
