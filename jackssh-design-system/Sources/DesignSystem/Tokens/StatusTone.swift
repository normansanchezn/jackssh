import SwiftUI

/// Visual severity vocabulary for the design system. Feature layers map their
/// own domain states onto a tone; the design system stays domain-agnostic.
public enum StatusTone: String, Sendable, CaseIterable {
    case positive
    case warning
    case critical
    case neutral

    public var color: Color {
        switch self {
        case .positive: return .green
        case .warning: return .orange
        case .critical: return .red
        case .neutral: return .secondary
        }
    }

    /// SF Symbol representing the tone. Filled for clear glanceability.
    public var symbolName: String {
        switch self {
        case .positive: return "checkmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .critical: return "xmark.octagon.fill"
        case .neutral: return "questionmark.circle.fill"
        }
    }
}
