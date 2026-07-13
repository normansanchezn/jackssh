import SwiftUI

// MARK: - Color Tokens

/// A comprehensive color palette for theming your app.
///
/// `DSColorTokens` provides a complete set of semantic colors organized into
/// multiple scales and categories. Use these tokens to maintain consistent
/// color usage throughout your app and support both light and dark modes.
///
/// ## Overview
///
/// The color system is organized into several categories:
///
/// ### Color Scales
/// - **Neutral**: Grayscale colors from lightest (50) to darkest (900)
/// - **Primary**: Brand colors for primary actions and emphasis
/// - **Secondary**: Accent colors for secondary elements
///
/// ### Semantic Colors
/// - **Status**: Success, warning, error, and info states
/// - **Surface**: Backgrounds and containers
/// - **Text**: Typography in various emphasis levels
///
/// ## Usage
///
/// Access colors through the theme environment:
///
/// ```swift
/// struct MyView: View {
///     @Environment(\.jacksshTheme) var theme
///
///     var body: some View {
///         Text("Hello")
///             .foregroundStyle(theme.colors.textPrimary)
///             .background(theme.colors.surface)
///     }
/// }
/// ```
///
/// ## Color Scale Convention
///
/// Color scales range from 50 (lightest) to 900 (darkest):
/// - **50-200**: Very light tints
/// - **300-400**: Light shades
/// - **500-600**: Main colors (most commonly used)
/// - **700-800**: Dark shades
/// - **900**: Very dark tones
///
/// In dark mode, the numerical values typically invert: what was 50 becomes
/// darker and what was 900 becomes lighter, maintaining appropriate contrast.
///
/// ## Topics
///
/// ### Color Scales
///
/// - ``neutral50``
/// - ``primary50``
/// - ``secondary50``
///
/// ### Semantic Colors
///
/// - ``success``
/// - ``warning``
/// - ``error``
/// - ``info``
///
/// ### Surface Colors
///
/// - ``background``
/// - ``surface``
/// - ``surfaceElevated``
/// - ``border``
///
/// ### Text Colors
///
/// - ``textPrimary``
/// - ``textSecondary``
/// - ``textTertiary``
/// - ``textInverse``
///
/// ### Status Colors
///
/// - ``statusConnected``
/// - ``statusDisconnected``
/// - ``statusPending``
///
public struct DSColorTokens: Sendable {
    // MARK: - Neutral Scale
    
    /// Neutral color scale - Lightest shade (50).
    ///
    /// Use for very subtle backgrounds or the lightest possible gray.
    public let neutral50: Color
    
    /// Neutral color scale - Very light gray (100).
    public let neutral100: Color
    
    /// Neutral color scale - Light gray (200).
    public let neutral200: Color
    
    /// Neutral color scale - Soft gray (300).
    public let neutral300: Color
    
    /// Neutral color scale - Medium-light gray (400).
    public let neutral400: Color
    
    /// Neutral color scale - Medium gray (500).
    public let neutral500: Color
    
    /// Neutral color scale - Medium-dark gray (600).
    public let neutral600: Color
    
    /// Neutral color scale - Dark gray (700).
    public let neutral700: Color
    
    /// Neutral color scale - Very dark gray (800).
    public let neutral800: Color
    
    /// Neutral color scale - Darkest shade (900).
    ///
    /// Use for the deepest shadows or darkest possible gray.
    public let neutral900: Color

    // MARK: - Primary Scale
    
    /// Primary brand color scale - Lightest shade (50).
    public let primary50: Color
    
    /// Primary brand color scale - Very light (100).
    public let primary100: Color
    
    /// Primary brand color scale - Light (200).
    public let primary200: Color
    
    /// Primary brand color scale - Soft (300).
    public let primary300: Color
    
    /// Primary brand color scale - Medium-light (400).
    public let primary400: Color
    
    /// Primary brand color scale - Medium (500).
    public let primary500: Color
    
    /// Primary brand color (600) - The main brand color.
    ///
    /// This is the primary color used throughout the app for buttons,
    /// links, and other interactive elements. Hex: `#4EACF9`
    public let primary600: Color
    
    /// Primary brand color scale - Dark (700).
    public let primary700: Color
    
    /// Primary brand color scale - Very dark (800).
    public let primary800: Color
    
    /// Primary brand color scale - Darkest shade (900).
    public let primary900: Color

    // MARK: - Secondary Scale
    
    /// Secondary accent color scale - Lightest shade (50).
    public let secondary50: Color
    
    /// Secondary accent color scale - Very light (100).
    public let secondary100: Color
    
    /// Secondary accent color scale - Light (200).
    public let secondary200: Color
    
    /// Secondary accent color scale - Soft (300).
    public let secondary300: Color
    
    /// Secondary accent color scale - Medium-light (400).
    public let secondary400: Color
    
    /// Secondary accent color scale - Medium (500).
    public let secondary500: Color
    
    /// Secondary accent color (600) - Main secondary color.
    public let secondary600: Color
    
    /// Secondary accent color scale - Dark (700).
    public let secondary700: Color
    
    /// Secondary accent color scale - Very dark (800).
    public let secondary800: Color
    
    /// Secondary accent color scale - Darkest shade (900).
    public let secondary900: Color

    // MARK: - Semantic Colors
    
    /// Color indicating successful operations or positive states.
    ///
    /// Use for success messages, checkmarks, and confirmations.
    public let success: Color
    
    /// Color indicating warnings or caution.
    ///
    /// Use for warning messages and alerts that need attention.
    public let warning: Color
    
    /// Color indicating errors or destructive actions.
    ///
    /// Use for error messages, failed operations, and delete actions.
    public let error: Color
    
    /// Color for informational messages and neutral highlights.
    ///
    /// Use for informational callouts and tips.
    public let info: Color

    // MARK: - Surface Colors
    
    /// The main background color for the app.
    ///
    /// Use as the base layer for most screens and views.
    public let background: Color
    
    /// Standard surface color for cards and containers.
    ///
    /// Use for cards, panels, and other content containers.
    public let surface: Color
    
    /// Elevated surface color with more contrast than standard surface.
    ///
    /// Use for modals, popovers, and elevated cards that need more emphasis.
    public let surfaceElevated: Color
    
    /// Border color for dividers and outlines.
    ///
    /// Use for separators, borders, and subtle dividing lines.
    public let border: Color

    // MARK: - Text Colors
    
    /// Primary text color with maximum contrast.
    ///
    /// Use for main headings, titles, and important text content.
    public let textPrimary: Color
    
    /// Secondary text color with medium contrast.
    ///
    /// Use for body text, descriptions, and less emphasized content.
    public let textSecondary: Color
    
    /// Tertiary text color with minimal contrast.
    ///
    /// Use for captions, hints, and the least important text.
    public let textTertiary: Color
    
    /// Inverse text color for use on colored backgrounds.
    ///
    /// Use for text on buttons, badges, and other filled components.
    public let textInverse: Color

    // MARK: - Status Colors
    
    /// Color indicating an active, connected state.
    ///
    /// Use for connection indicators showing successful connections.
    public let statusConnected: Color
    
    /// Color indicating a disconnected or inactive state.
    ///
    /// Use for connection indicators showing disconnection.
    public let statusDisconnected: Color
    
    /// Color indicating a pending or in-progress state.
    ///
    /// Use for connection indicators showing connecting or loading states.
    public let statusPending: Color
}

// MARK: - Light Mode Colors

/// The default light mode color palette.
///
/// Use this palette when your app is in light mode or when you need to
/// explicitly reference light mode colors.
///
/// ## Overview
///
/// This palette provides high contrast colors optimized for readability
/// in well-lit environments. Background colors are light, and text colors
/// are dark for maximum legibility.
///
/// Access through the theme:
/// ```swift
/// @Environment(\.jacksshTheme) var theme
/// // Automatically uses lightColorTokens in light mode
/// ```
public let lightColorTokens = DSColorTokens(
    // Neutral
    neutral50: Color(red: 0.98, green: 0.98, blue: 0.98),
    neutral100: Color(red: 0.96, green: 0.96, blue: 0.96),
    neutral200: Color(red: 0.90, green: 0.90, blue: 0.90),
    neutral300: Color(red: 0.82, green: 0.82, blue: 0.82),
    neutral400: Color(red: 0.72, green: 0.72, blue: 0.72),
    neutral500: Color(red: 0.60, green: 0.60, blue: 0.60),
    neutral600: Color(red: 0.45, green: 0.45, blue: 0.45),
    neutral700: Color(red: 0.32, green: 0.32, blue: 0.32),
    neutral800: Color(red: 0.18, green: 0.18, blue: 0.18),
    neutral900: Color(red: 0.08, green: 0.08, blue: 0.08),

    // Primary (Blue)
    primary50: Color(red: 0.93, green: 0.98, blue: 1.0),
    primary100: Color(red: 0.84, green: 0.94, blue: 1.0),
    primary200: Color(red: 0.70, green: 0.88, blue: 1.0),
    primary300: Color(red: 0.56, green: 0.81, blue: 0.99),
    primary400: Color(red: 0.43, green: 0.74, blue: 0.99),
    primary500: Color(red: 0.36, green: 0.70, blue: 0.98),
    primary600: Color(red: 0.3059, green: 0.6745, blue: 0.9765), // #4EACF9
    primary700: Color(red: 0.22, green: 0.54, blue: 0.78),
    primary800: Color(red: 0.16, green: 0.40, blue: 0.60),
    primary900: Color(red: 0.10, green: 0.26, blue: 0.40),

    // Secondary mirrors the brand blue scale for non-primary accents.
    secondary50: Color(red: 0.93, green: 0.98, blue: 1.0),
    secondary100: Color(red: 0.84, green: 0.94, blue: 1.0),
    secondary200: Color(red: 0.70, green: 0.88, blue: 1.0),
    secondary300: Color(red: 0.56, green: 0.81, blue: 0.99),
    secondary400: Color(red: 0.43, green: 0.74, blue: 0.99),
    secondary500: Color(red: 0.36, green: 0.70, blue: 0.98),
    secondary600: Color(red: 0.3059, green: 0.6745, blue: 0.9765),
    secondary700: Color(red: 0.22, green: 0.54, blue: 0.78),
    secondary800: Color(red: 0.16, green: 0.40, blue: 0.60),
    secondary900: Color(red: 0.10, green: 0.26, blue: 0.40),

    // Semantic
    success: Color(red: 0.20, green: 0.78, blue: 0.35),
    warning: Color(red: 1.0, green: 0.65, blue: 0.0),
    error: Color(red: 0.91, green: 0.18, blue: 0.29),
    info: Color(red: 0.3059, green: 0.6745, blue: 0.9765),

    // Surface
    background: Color(red: 0.99, green: 0.99, blue: 0.99),
    surface: Color(red: 1.0, green: 1.0, blue: 1.0),
    surfaceElevated: Color(red: 0.96, green: 0.96, blue: 0.96),
    border: Color(red: 0.90, green: 0.90, blue: 0.90),

    // Text
    textPrimary: Color(red: 0.08, green: 0.08, blue: 0.08),
    textSecondary: Color(red: 0.32, green: 0.32, blue: 0.32),
    textTertiary: Color(red: 0.60, green: 0.60, blue: 0.60),
    textInverse: Color(red: 0.018, green: 0.027, blue: 0.043),

    // Status
    statusConnected: Color(red: 0.20, green: 0.78, blue: 0.35),
    statusDisconnected: Color(red: 0.60, green: 0.60, blue: 0.60),
    statusPending: Color(red: 1.0, green: 0.65, blue: 0.0)
)

// MARK: - Dark Mode Colors

/// The default dark mode color palette.
///
/// Use this palette when your app is in dark mode or when you need to
/// explicitly reference dark mode colors.
///
/// ## Overview
///
/// This palette provides optimized colors for viewing in low-light conditions.
/// Background colors are dark, and text colors are light for comfortable
/// nighttime viewing. Primary colors are brightened to maintain visibility
/// against dark backgrounds.
///
/// Access through the theme:
/// ```swift
/// @Environment(\.jacksshTheme) var theme
/// // Automatically uses darkColorTokens in dark mode
/// ```
public let darkColorTokens = DSColorTokens(
    // Neutral
    neutral50: Color(red: 0.025, green: 0.035, blue: 0.052),
    neutral100: Color(red: 0.045, green: 0.060, blue: 0.085),
    neutral200: Color(red: 0.075, green: 0.095, blue: 0.125),
    neutral300: Color(red: 0.120, green: 0.145, blue: 0.175),
    neutral400: Color(red: 0.190, green: 0.220, blue: 0.255),
    neutral500: Color(red: 0.340, green: 0.375, blue: 0.415),
    neutral600: Color(red: 0.500, green: 0.540, blue: 0.585),
    neutral700: Color(red: 0.690, green: 0.720, blue: 0.755),
    neutral800: Color(red: 0.840, green: 0.865, blue: 0.890),
    neutral900: Color(red: 0.940, green: 0.955, blue: 0.970),

    // Primary (Blue) — lighter in dark mode
    primary50: Color(red: 0.040, green: 0.085, blue: 0.125),
    primary100: Color(red: 0.060, green: 0.130, blue: 0.190),
    primary200: Color(red: 0.085, green: 0.195, blue: 0.290),
    primary300: Color(red: 0.115, green: 0.295, blue: 0.450),
    primary400: Color(red: 0.165, green: 0.430, blue: 0.660),
    primary500: Color(red: 0.230, green: 0.570, blue: 0.840),
    primary600: Color(red: 0.3059, green: 0.6745, blue: 0.9765), // #4EACF9
    primary700: Color(red: 0.480, green: 0.760, blue: 1.0),
    primary800: Color(red: 0.680, green: 0.860, blue: 1.0),
    primary900: Color(red: 0.870, green: 0.950, blue: 1.0),

    // Secondary mirrors the brand blue scale for non-primary accents.
    secondary50: Color(red: 0.040, green: 0.085, blue: 0.125),
    secondary100: Color(red: 0.060, green: 0.130, blue: 0.190),
    secondary200: Color(red: 0.085, green: 0.195, blue: 0.290),
    secondary300: Color(red: 0.115, green: 0.295, blue: 0.450),
    secondary400: Color(red: 0.165, green: 0.430, blue: 0.660),
    secondary500: Color(red: 0.230, green: 0.570, blue: 0.840),
    secondary600: Color(red: 0.3059, green: 0.6745, blue: 0.9765),
    secondary700: Color(red: 0.480, green: 0.760, blue: 1.0),
    secondary800: Color(red: 0.680, green: 0.860, blue: 1.0),
    secondary900: Color(red: 0.870, green: 0.950, blue: 1.0),

    // Semantic
    success: Color(red: 0.200, green: 0.780, blue: 0.350),
    warning: Color(red: 0.980, green: 0.700, blue: 0.220),
    error: Color(red: 1.000, green: 0.320, blue: 0.500),
    info: Color(red: 0.3059, green: 0.6745, blue: 0.9765),

    // Surface
    background: Color(red: 0.018, green: 0.027, blue: 0.043),
    surface: Color(red: 0.055, green: 0.070, blue: 0.095),
    surfaceElevated: Color(red: 0.085, green: 0.105, blue: 0.135),
    border: Color(red: 0.205, green: 0.250, blue: 0.300),

    // Text
    textPrimary: Color(red: 0.930, green: 0.960, blue: 0.985),
    textSecondary: Color(red: 0.670, green: 0.730, blue: 0.790),
    textTertiary: Color(red: 0.410, green: 0.470, blue: 0.535),
    textInverse: Color(red: 0.018, green: 0.027, blue: 0.043),

    // Status
    statusConnected: Color(red: 0.200, green: 0.780, blue: 0.350),
    statusDisconnected: Color(red: 1.000, green: 0.320, blue: 0.500),
    statusPending: Color(red: 0.980, green: 0.700, blue: 0.220)
)
