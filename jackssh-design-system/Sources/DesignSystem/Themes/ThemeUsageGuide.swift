import SwiftUI

/// Guide: How to use JacksshTheme in components
///
/// All views automatically get theme support via @Environment(\.jacksshTheme).
/// The theme responds to system dark/light mode automatically.
///
/// Example 1: Basic color usage
/// ```swift
/// struct MyButton: View {
///     @Environment(\.jacksshTheme) var theme
///
///     var body: some View {
///         Button(action: {}) {
///             Text("Tap me")
///                 .foregroundStyle(theme.colors.textInverse)
///         }
///         .buttonStyle(.plain)
///         .padding(theme.spacing.md)
///         .background(theme.colors.primary500)
///         .cornerRadius(theme.radius.md)
///     }
/// }
/// ```
///
/// Example 2: Semantic colors (recommended)
/// ```swift
/// struct StatusIndicator: View {
///     @Environment(\.jacksshTheme) var theme
///     let isConnected: Bool
///
///     var body: some View {
///         Circle()
///             .fill(isConnected ? theme.colors.statusConnected : theme.colors.statusDisconnected)
///             .frame(width: 12, height: 12)
///     }
/// }
/// ```
///
/// Example 3: Light/Dark mode awareness
/// ```swift
/// struct Card: View {
///     @Environment(\.jacksshTheme) var theme
///     @Environment(\.colorScheme) var colorScheme
///
///     var body: some View {
///         VStack {
///             Text("Card Content")
///                 .foregroundStyle(theme.colors.textPrimary)
///         }
///         .padding(theme.spacing.lg)
///         .background(theme.colors.surface)
///         .border(theme.colors.border, width: 1)
///         .cornerRadius(theme.radius.md)
///     }
/// }
/// ```
///
/// Available color tokens:
///   - textPrimary: Primary text (black in light, white in dark)
///   - textSecondary: Secondary text (gray)
///   - textTertiary: Tertiary text (lighter gray)
///   - textInverse: Inverse text (white in light, black in dark)
///   - background: Main background
///   - surface: Card/elevated background
///   - surfaceElevated: Higher elevation background
///   - border: Border color
///   - primary500: Brand blue
///   - secondary500: Brand blue accent
///   - success: Green (✓)
///   - warning: Orange (⚠)
///   - error: Red (✗)
///   - info: Blue (ℹ)
///   - statusConnected: Green
///   - statusDisconnected: Gray
///   - statusPending: Orange
///   - neutralXXX: Gray scale (50-900)
///   - primaryXXX: Blue scale (50-900)
///   - secondaryXXX: Blue accent scale (50-900)
