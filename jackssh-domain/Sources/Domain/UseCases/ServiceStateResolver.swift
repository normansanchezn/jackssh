import Foundation

/// Raw signals observed for a service, before interpretation.
public struct ServiceProbe: Equatable, Sendable {
    public let reachable: Bool
    public let running: Bool
    /// Fraction of recent health checks that passed, 0...1. `nil` when unknown.
    public let healthyRatio: Double?

    public init(reachable: Bool, running: Bool, healthyRatio: Double? = nil) {
        self.reachable = reachable
        self.running = running
        self.healthyRatio = healthyRatio
    }
}

/// Pure mapping from raw probe signals to a `HealthState`. No I/O — fully testable.
public enum ServiceStateResolver {
    public static func resolve(_ probe: ServiceProbe) -> HealthState {
        guard probe.reachable else { return .offline }
        guard probe.running else { return .offline }
        guard let ratio = probe.healthyRatio else { return .unknown }
        if ratio >= 0.99 { return .online }
        if ratio > 0 { return .degraded }
        return .offline
    }
}
