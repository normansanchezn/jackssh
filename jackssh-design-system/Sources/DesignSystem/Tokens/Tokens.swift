import SwiftUI

/// Design tokens — the single source of spacing, radius, and typography values.
/// Everything visual in the app derives from these; no magic numbers in views.

public enum DSSpacing {
    public static let xxs: CGFloat = 2
    public static let xs: CGFloat = 4
    public static let sm: CGFloat = 8
    public static let md: CGFloat = 12
    public static let lg: CGFloat = 16
    public static let xl: CGFloat = 24
    public static let xxl: CGFloat = 32
}

public enum DSRadius {
    public static let xs: CGFloat = 8
    public static let sm: CGFloat = 12
    public static let md: CGFloat = 16
    public static let lg: CGFloat = 20
}

/// Semantic typography. All styles are relative to Dynamic Type text styles,
/// so they scale with the user's preferred content size automatically.
public enum DSTypography {
    public static let screenTitle: Font = .system(.title2, design: .default, weight: .bold)
    public static let sectionTitle: Font = .system(.headline, design: .default, weight: .semibold)
    public static let body: Font = .system(.subheadline, design: .default)
    public static let caption: Font = .system(.caption2, design: .default)
    public static let mono: Font = .system(.caption, design: .monospaced)
    public static let monoBody: Font = .system(.subheadline, design: .monospaced)
}
