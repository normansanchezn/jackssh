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
    public static let sm: CGFloat = 8
    public static let md: CGFloat = 12
    public static let lg: CGFloat = 16
}

/// Semantic typography. All styles are relative to Dynamic Type text styles,
/// so they scale with the user's preferred content size automatically.
public enum DSTypography {
    public static let screenTitle: Font = .system(.largeTitle, design: .rounded, weight: .bold)
    public static let sectionTitle: Font = .system(.headline, design: .rounded)
    public static let body: Font = .body
    public static let caption: Font = .caption
    public static let mono: Font = .system(.body, design: .monospaced)
}
