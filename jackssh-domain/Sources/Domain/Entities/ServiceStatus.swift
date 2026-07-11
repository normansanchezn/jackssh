import Foundation

/// Resolved health state shared by hosts, services, and integrations.
public enum HealthState: String, Sendable, CaseIterable, Equatable {
    case online
    case degraded
    case offline
    case unknown
}

/// A known service the console can observe (OpenClaw, Docker, Ollama bridge, ...).
public enum ServiceKind: String, Sendable, CaseIterable, Equatable {
    case openClaw
    case docker
    case ollamaBridge
}

/// Current status of a single service.
public struct ServiceStatus: Identifiable, Equatable, Sendable {
    public var id: ServiceKind { kind }
    public let kind: ServiceKind
    public let state: HealthState
    public let detail: String?

    public init(kind: ServiceKind, state: HealthState, detail: String? = nil) {
        self.kind = kind
        self.state = state
        self.detail = detail
    }
}
