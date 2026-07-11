import Domain
import DesignSystem

/// Bridges the domain `HealthState` onto the design system's visual `StatusTone`.
/// Keeps DesignSystem free of any domain knowledge.
extension HealthState {
    public var tone: StatusTone {
        switch self {
        case .online: return .positive
        case .degraded: return .warning
        case .offline: return .critical
        case .unknown: return .neutral
        }
    }

    public var label: String {
        switch self {
        case .online: return "Online"
        case .degraded: return "Degraded"
        case .offline: return "Offline"
        case .unknown: return "Unknown"
        }
    }
}
