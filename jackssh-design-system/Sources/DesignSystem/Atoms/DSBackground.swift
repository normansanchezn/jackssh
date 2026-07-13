import SwiftUI

/// A full-screen background with optional grid overlay for console-style interfaces.
///
/// `DSBackground` creates a dark, atmospheric background with gradient effects
/// and an optional terminal-style grid. Use it as the base layer for authentication
/// screens, dashboards, and other full-screen views that need a professional,
/// technical aesthetic.
///
/// ## Overview
///
/// The background combines multiple visual layers:
/// - A solid base color from your theme
/// - A subtle gradient for depth
/// - An optional monospaced grid overlay
///
/// ## Creating a Background
///
/// Basic usage without grid:
///
/// ```swift
/// DSBackground {
///     // Your content here
///     Text("Console Interface")
/// }
/// ```
///
/// With grid overlay for terminal-style screens:
///
/// ```swift
/// DSBackground(showGrid: true) {
///     // Your content here
///     TerminalView()
/// }
/// ```
///
/// ## Styling
///
/// The background automatically adapts to your app's theme using the
/// `jacksshTheme` environment value. It extends to all screen edges,
/// ignoring safe areas to create a truly immersive experience.
///
/// ## Topics
///
/// ### Creating Backgrounds
///
/// - ``init(showGrid:content:)``
///
/// ### Related Components
///
/// - ``DSBackgroundElevated``
///
public struct DSBackground<Content: View>: View {
    @Environment(\.jacksshTheme) var theme
    private let content: () -> Content
    private let showGrid: Bool
    
    /// Creates a background view with optional grid overlay.
    ///
    /// - Parameters:
    ///   - showGrid: Whether to display the terminal-style grid overlay. Defaults to `false`.
    ///   - content: A view builder that creates the foreground content.
    ///
    /// ## Example
    ///
    /// ```swift
    /// DSBackground(showGrid: true) {
    ///     VStack {
    ///         Text("SSH Console")
    ///         TerminalView()
    ///     }
    /// }
    /// ```
    public init(showGrid: Bool = false, @ViewBuilder content: @escaping () -> Content) {
        self.showGrid = showGrid
        self.content = content
    }

    public var body: some View {
        ZStack {
            theme.colors.background
                .ignoresSafeArea(.container)

            LinearGradient(
                colors: [
                    theme.colors.primary100.opacity(0.20),
                    theme.colors.background.opacity(0.20),
                    theme.colors.background
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea(.container)

            if showGrid {
                Canvas { context, size in
                    let cellWidth: CGFloat = 12
                    let cellHeight: CGFloat = 18
                    
                    var x: CGFloat = 0
                    while x < size.width {
                        context.stroke(
                            Path { path in
                                path.move(to: CGPoint(x: x, y: 0))
                                path.addLine(to: CGPoint(x: x, y: size.height))
                            },
                            with: .color(theme.colors.border.opacity(0.45)),
                            lineWidth: 0.3
                        )
                        x += cellWidth
                    }
                    
                    var y: CGFloat = 0
                    while y < size.height {
                        context.stroke(
                            Path { path in
                                path.move(to: CGPoint(x: 0, y: y))
                                path.addLine(to: CGPoint(x: size.width, y: y))
                            },
                            with: .color(theme.colors.border.opacity(0.38)),
                            lineWidth: 0.3
                        )
                        y += cellHeight
                    }
                }
                .opacity(0.45)
                .blendMode(.overlay)
                .ignoresSafeArea(.container)
            }

            content()
        }
    }
}

/// An elevated card-style container with Liquid Glass visual effects.
///
/// `DSBackgroundElevated` wraps content in a translucent, elevated surface with:
/// - Ultra-thin material background
/// - Gradient overlay
/// - Luminous border highlights
/// - Subtle shadow
///
/// ## Overview
///
/// Use elevated backgrounds to create visual hierarchy and separate content
/// from the base background. Perfect for cards, panels, and modal content.
///
/// ## Creating an Elevated Background
///
/// ```swift
/// DSBackgroundElevated {
///     VStack {
///         Text("Settings")
///             .font(.headline)
///         Toggle("Notifications", isOn: $enabled)
///     }
/// }
/// ```
///
/// Custom corner radius:
///
/// ```swift
/// DSBackgroundElevated(cornerRadius: 20) {
///     // Your content
/// }
/// ```
///
/// ## Visual Design
///
/// The component automatically adapts its appearance based on:
/// - Current color scheme (light or dark mode)
/// - Theme colors from the environment
/// - System materials for platform consistency
///
/// ## Topics
///
/// ### Creating Elevated Backgrounds
///
/// - ``init(cornerRadius:content:)``
///
public struct DSBackgroundElevated<Content: View>: View {
    @Environment(\.jacksshTheme) var theme
    @Environment(\.colorScheme) var colorScheme
    private let content: () -> Content
    private let cornerRadius: CGFloat
    
    /// Creates an elevated background container with rounded corners.
    ///
    /// - Parameters:
    ///   - cornerRadius: The corner radius for the background shape. Defaults to `12`.
    ///   - content: A view builder that creates the foreground content.
    ///
    /// ## Example
    ///
    /// ```swift
    /// DSBackgroundElevated(cornerRadius: 16) {
    ///     VStack(spacing: 12) {
    ///         Image(systemName: "checkmark.circle.fill")
    ///         Text("Success")
    ///     }
    /// }
    /// ```
    public init(
        cornerRadius: CGFloat = 12,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.content = content
    }

    public var body: some View {
        content()
            .padding(DSSpacing.md)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(.ultraThinMaterial)
                    
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(
                            LinearGradient(
                                colors: [
                                    theme.colors.surfaceElevated.opacity(0.2),
                                    theme.colors.surfaceElevated.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    .white.opacity(colorScheme == .dark ? 0.2 : 0.4),
                                    .white.opacity(colorScheme == .dark ? 0.05 : 0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
                .shadow(
                    color: .black.opacity(colorScheme == .dark ? 0.5 : 0.1),
                    radius: 20,
                    x: 0,
                    y: 10
                )
            }
    }
}
