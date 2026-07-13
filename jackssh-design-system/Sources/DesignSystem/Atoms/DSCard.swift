import SwiftUI

/// A rounded container with Liquid Glass styling for grouping related content.
///
/// `DSCard` provides a consistent card interface with translucent background,
/// subtle borders, and automatic padding. Use cards to group related information
/// and create visual hierarchy in your layouts.
///
/// ## Overview
///
/// Cards are fundamental building blocks for structured layouts. They:
/// - Contain related content
/// - Create visual separation
/// - Support both light and dark modes
/// - Use Liquid Glass aesthetics
///
/// ## Creating a Card
///
/// Basic card with text content:
///
/// ```swift
/// DSCard {
///     VStack(alignment: .leading, spacing: 8) {
///         Text("Server Status")
///             .font(.headline)
///         Text("All systems operational")
///             .font(.caption)
///             .foregroundStyle(.secondary)
///     }
/// }
/// ```
///
/// Card with multiple sections:
///
/// ```swift
/// DSCard {
///     VStack(spacing: DSSpacing.md) {
///         HStack {
///             Text("Connection")
///             Spacer()
///             Image(systemName: "checkmark.circle.fill")
///                 .foregroundStyle(.green)
///         }
///         
///         Divider()
///         
///         Text("Host: example.com")
///             .font(.caption)
///             .foregroundStyle(.secondary)
///     }
/// }
/// ```
///
/// ## Layout
///
/// Cards automatically:
/// - Add padding around content (`DSSpacing.lg`)
/// - Expand to fill available width
/// - Align content to leading edge by default
///
/// ## Styling
///
/// Cards use ``DSGlassSurface`` for consistent Liquid Glass appearance
/// across the design system.
///
/// ## Topics
///
/// ### Creating Cards
///
/// - ``init(content:)``
///
/// ### Related Components
///
/// - ``DSGlassSurface``
/// - ``DSBackgroundElevated``
///
public struct DSCard<Content: View>: View {
    private let content: Content

    /// Creates a card container with the specified content.
    ///
    /// - Parameter content: A view builder closure that creates the card's content.
    ///
    /// ## Example
    ///
    /// ```swift
    /// DSCard {
    ///     Text("Card content")
    ///         .font(.headline)
    /// }
    /// ```
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        DSGlassSurface {
            content
                .padding(DSSpacing.lg)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
