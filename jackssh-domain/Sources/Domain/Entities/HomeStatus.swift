import Foundation

/// An entry in the recent activity feed shown on Home.
public struct ActivityEvent: Identifiable, Equatable, Sendable {
    public let id: UUID
    public let title: String
    public let timestamp: Date
    public let state: HealthState

    public init(id: UUID = UUID(), title: String, timestamp: Date, state: HealthState = .unknown) {
        self.id = id
        self.title = title
        self.timestamp = timestamp
        self.state = state
    }
}

/// Aggregated snapshot rendered by the Home feature.
public struct HomeStatus: Equatable, Sendable {
    public let privateNetworkOnline: Bool
    public let vps: HealthState
    public let openClaw: HealthState
    public let ollama: HealthState
    public let recentActivity: [ActivityEvent]

    public init(
        privateNetworkOnline: Bool,
        vps: HealthState,
        openClaw: HealthState,
        ollama: HealthState,
        recentActivity: [ActivityEvent]
    ) {
        self.privateNetworkOnline = privateNetworkOnline
        self.vps = vps
        self.openClaw = openClaw
        self.ollama = ollama
        self.recentActivity = recentActivity
    }
}
