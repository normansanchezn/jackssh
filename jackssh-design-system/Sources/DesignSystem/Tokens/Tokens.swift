import SwiftUI

/// Spacing values for consistent layout throughout the app.
///
/// `DSSpacing` provides a unified scale of spacing values to maintain
/// visual consistency and rhythm across all screens and components.
///
/// ## Overview
///
/// Use these spacing values instead of arbitrary numbers to ensure your
/// layouts feel cohesive and professional. The scale follows a
/// geometric progression optimized for readability and visual hierarchy.
///
/// ## Usage
///
/// Apply spacing in SwiftUI views:
///
/// ```swift
/// VStack(spacing: DSSpacing.md) {
///     Text("Title")
///     Text("Description")
/// }
/// .padding(DSSpacing.lg)
/// ```
///
/// ## Spacing Scale
///
/// | Value | Size | Use Case |
/// |-------|------|----------|
/// | `xxs` | 2pt  | Minimal gaps, icon offsets |
/// | `xs`  | 4pt  | Tight spacing within components |
/// | `sm`  | 8pt  | Small gaps between related items |
/// | `md`  | 12pt | Standard component spacing |
/// | `lg`  | 16pt | Section spacing |
/// | `xl`  | 24pt | Large gaps between major sections |
/// | `xxl` | 32pt | Maximum spacing for screen edges |
///
/// ## Topics
///
/// ### Spacing Values
///
/// - ``xxs``
/// - ``xs``
/// - ``sm``
/// - ``md``
/// - ``lg``
/// - ``xl``
/// - ``xxl``
///
public enum DSSpacing {
    /// Extra-extra-small spacing: 2 points.
    ///
    /// Use for minimal gaps, icon offsets, or fine adjustments.
    public static let xxs: CGFloat = 2
    
    /// Extra-small spacing: 4 points.
    ///
    /// Use for tight spacing within compact components.
    public static let xs: CGFloat = 4
    
    /// Small spacing: 8 points.
    ///
    /// Use for small gaps between closely related items.
    public static let sm: CGFloat = 8
    
    /// Medium spacing: 12 points.
    ///
    /// This is the standard spacing for most component layouts.
    public static let md: CGFloat = 12
    
    /// Large spacing: 16 points.
    ///
    /// Use for separating sections or grouping related content.
    public static let lg: CGFloat = 16
    
    /// Extra-large spacing: 24 points.
    ///
    /// Use for large gaps between major sections.
    public static let xl: CGFloat = 24
    
    /// Extra-extra-large spacing: 32 points.
    ///
    /// Use for maximum spacing at screen edges or between major views.
    public static let xxl: CGFloat = 32
}

/// Corner radius values for consistent shapes throughout the app.
///
/// `DSRadius` provides standardized corner radius values to maintain
/// visual consistency across all rounded shapes, cards, and buttons.
///
/// ## Overview
///
/// Apply these radius values to create harmonious, modern interfaces
/// with consistent corner treatments.
///
/// ## Usage
///
/// ```swift
/// RoundedRectangle(cornerRadius: DSRadius.md)
///     .fill(Color.blue)
/// ```
///
/// ## Radius Scale
///
/// | Value | Size | Use Case |
/// |-------|------|----------|
/// | `xs`  | 8pt  | Small buttons, chips |
/// | `sm`  | 12pt | Standard buttons |
/// | `md`  | 16pt | Cards, input fields |
/// | `lg`  | 20pt | Large cards, modals |
///
/// ## Topics
///
/// ### Radius Values
///
/// - ``xs``
/// - ``sm``
/// - ``md``
/// - ``lg``
///
public enum DSRadius {
    /// Extra-small radius: 8 points.
    ///
    /// Use for small buttons, chips, or compact components.
    public static let xs: CGFloat = 8
    
    /// Small radius: 12 points.
    ///
    /// Use for standard buttons and small cards.
    public static let sm: CGFloat = 12
    
    /// Medium radius: 16 points.
    ///
    /// Use for cards, input fields, and standard containers.
    public static let md: CGFloat = 16
    
    /// Large radius: 20 points.
    ///
    /// Use for large cards, modals, and prominent containers.
    public static let lg: CGFloat = 20
}

/// Semantic typography styles with automatic Dynamic Type support.
///
/// `DSTypography` provides a type scale that adapts to the user's preferred
/// text size settings, ensuring accessibility and readability across all devices.
///
/// ## Overview
///
/// All typography styles are based on system text styles that scale with
/// Dynamic Type. Use these semantic styles instead of arbitrary font sizes.
///
/// ## Usage
///
/// Apply typography in SwiftUI:
///
/// ```swift
/// Text("Welcome")
///     .font(DSTypography.screenTitle)
///
/// Text("Description text")
///     .font(DSTypography.body)
/// ```
///
/// ## Type Scale
///
/// | Style | Base Size | Weight | Design |
/// |-------|-----------|--------|--------|
/// | `screenTitle` | Title 2 | Bold | System |
/// | `sectionTitle` | Headline | Semibold | System |
/// | `body` | Subheadline | Regular | System |
/// | `caption` | Caption 2 | Regular | System |
/// | `mono` | Caption | Regular | Monospaced |
/// | `monoBody` | Subheadline | Regular | Monospaced |
///
/// ## Accessibility
///
/// All styles automatically scale with the user's preferred text size,
/// supporting all Dynamic Type sizes from Extra Small to Accessibility 5.
///
/// ## Topics
///
/// ### Text Styles
///
/// - ``screenTitle``
/// - ``sectionTitle``
/// - ``body``
/// - ``caption``
/// - ``mono``
/// - ``monoBody``
///
public enum DSTypography {
    /// Large, bold title for screen headers.
    ///
    /// Use for the main title at the top of a screen or view.
    /// Based on `.title2` with bold weight.
    public static let screenTitle: Font = .system(.title2, design: .default, weight: .bold)
    
    /// Medium-sized title for section headers.
    ///
    /// Use for subsection headings within a view.
    /// Based on `.headline` with semibold weight.
    public static let sectionTitle: Font = .system(.headline, design: .default, weight: .semibold)
    
    /// Standard body text for general content.
    ///
    /// Use for descriptions, labels, and general text content.
    /// Based on `.subheadline` with regular weight.
    public static let body: Font = .system(.subheadline, design: .default)
    
    /// Small caption text for secondary information.
    ///
    /// Use for timestamps, metadata, or supplementary information.
    /// Based on `.caption2` with regular weight.
    public static let caption: Font = .system(.caption2, design: .default)
    
    /// Monospaced font for code or technical data.
    ///
    /// Use for displaying code, paths, or technical identifiers.
    /// Based on `.caption` with monospaced design.
    public static let mono: Font = .system(.caption, design: .monospaced)
    
    /// Larger monospaced font for terminal output.
    ///
    /// Use for terminal content or command output.
    /// Based on `.subheadline` with monospaced design.
    public static let monoBody: Font = .system(.subheadline, design: .monospaced)
}
