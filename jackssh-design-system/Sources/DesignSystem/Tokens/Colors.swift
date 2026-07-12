import SwiftUI

// MARK: - Color Tokens

public struct DSColorTokens: Sendable {
    // Neutral scale (grays)
    public let neutral50: Color
    public let neutral100: Color
    public let neutral200: Color
    public let neutral300: Color
    public let neutral400: Color
    public let neutral500: Color
    public let neutral600: Color
    public let neutral700: Color
    public let neutral800: Color
    public let neutral900: Color

    // Primary brand (blue)
    public let primary50: Color
    public let primary100: Color
    public let primary200: Color
    public let primary300: Color
    public let primary400: Color
    public let primary500: Color
    public let primary600: Color
    public let primary700: Color
    public let primary800: Color
    public let primary900: Color

    // Secondary (teal)
    public let secondary50: Color
    public let secondary100: Color
    public let secondary200: Color
    public let secondary300: Color
    public let secondary400: Color
    public let secondary500: Color
    public let secondary600: Color
    public let secondary700: Color
    public let secondary800: Color
    public let secondary900: Color

    // Semantic colors
    public let success: Color
    public let warning: Color
    public let error: Color
    public let info: Color

    // Surface colors
    public let background: Color
    public let surface: Color
    public let surfaceElevated: Color
    public let border: Color

    // Text colors
    public let textPrimary: Color
    public let textSecondary: Color
    public let textTertiary: Color
    public let textInverse: Color

    // Status specific
    public let statusConnected: Color
    public let statusDisconnected: Color
    public let statusPending: Color
}

// MARK: - Light Mode Colors
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
    primary50: Color(red: 0.95, green: 0.97, blue: 1.0),
    primary100: Color(red: 0.88, green: 0.93, blue: 1.0),
    primary200: Color(red: 0.77, green: 0.87, blue: 1.0),
    primary300: Color(red: 0.63, green: 0.80, blue: 1.0),
    primary400: Color(red: 0.47, green: 0.71, blue: 1.0),
    primary500: Color(red: 0.25, green: 0.60, blue: 1.0),
    primary600: Color(red: 0.0, green: 0.48, blue: 1.0),
    primary700: Color(red: 0.0, green: 0.38, blue: 0.82),
    primary800: Color(red: 0.0, green: 0.29, blue: 0.63),
    primary900: Color(red: 0.0, green: 0.21, blue: 0.45),

    // Secondary (Teal)
    secondary50: Color(red: 0.94, green: 0.99, blue: 0.99),
    secondary100: Color(red: 0.85, green: 0.97, blue: 0.98),
    secondary200: Color(red: 0.71, green: 0.93, blue: 0.96),
    secondary300: Color(red: 0.55, green: 0.88, blue: 0.92),
    secondary400: Color(red: 0.35, green: 0.82, blue: 0.88),
    secondary500: Color(red: 0.10, green: 0.74, blue: 0.83),
    secondary600: Color(red: 0.0, green: 0.62, blue: 0.71),
    secondary700: Color(red: 0.0, green: 0.51, blue: 0.59),
    secondary800: Color(red: 0.0, green: 0.39, blue: 0.45),
    secondary900: Color(red: 0.0, green: 0.28, blue: 0.32),

    // Semantic
    success: Color(red: 0.16, green: 0.74, blue: 0.39),
    warning: Color(red: 1.0, green: 0.65, blue: 0.0),
    error: Color(red: 0.91, green: 0.18, blue: 0.29),
    info: Color(red: 0.25, green: 0.60, blue: 1.0),

    // Surface
    background: Color(red: 0.99, green: 0.99, blue: 0.99),
    surface: Color(red: 1.0, green: 1.0, blue: 1.0),
    surfaceElevated: Color(red: 0.96, green: 0.96, blue: 0.96),
    border: Color(red: 0.90, green: 0.90, blue: 0.90),

    // Text
    textPrimary: Color(red: 0.08, green: 0.08, blue: 0.08),
    textSecondary: Color(red: 0.32, green: 0.32, blue: 0.32),
    textTertiary: Color(red: 0.60, green: 0.60, blue: 0.60),
    textInverse: Color(red: 1.0, green: 1.0, blue: 1.0),

    // Status
    statusConnected: Color(red: 0.16, green: 0.74, blue: 0.39),
    statusDisconnected: Color(red: 0.60, green: 0.60, blue: 0.60),
    statusPending: Color(red: 1.0, green: 0.65, blue: 0.0)
)

// MARK: - Dark Mode Colors
public let darkColorTokens = DSColorTokens(
    // Neutral
    neutral50: Color(red: 0.08, green: 0.08, blue: 0.08),
    neutral100: Color(red: 0.12, green: 0.12, blue: 0.12),
    neutral200: Color(red: 0.18, green: 0.18, blue: 0.18),
    neutral300: Color(red: 0.26, green: 0.26, blue: 0.26),
    neutral400: Color(red: 0.35, green: 0.35, blue: 0.35),
    neutral500: Color(red: 0.45, green: 0.45, blue: 0.45),
    neutral600: Color(red: 0.56, green: 0.56, blue: 0.56),
    neutral700: Color(red: 0.72, green: 0.72, blue: 0.72),
    neutral800: Color(red: 0.82, green: 0.82, blue: 0.82),
    neutral900: Color(red: 0.96, green: 0.96, blue: 0.96),

    // Primary (Blue) — lighter in dark mode
    primary50: Color(red: 0.0, green: 0.21, blue: 0.45),
    primary100: Color(red: 0.0, green: 0.29, blue: 0.63),
    primary200: Color(red: 0.0, green: 0.38, blue: 0.82),
    primary300: Color(red: 0.0, green: 0.48, blue: 1.0),
    primary400: Color(red: 0.25, green: 0.60, blue: 1.0),
    primary500: Color(red: 0.47, green: 0.71, blue: 1.0),
    primary600: Color(red: 0.63, green: 0.80, blue: 1.0),
    primary700: Color(red: 0.77, green: 0.87, blue: 1.0),
    primary800: Color(red: 0.88, green: 0.93, blue: 1.0),
    primary900: Color(red: 0.95, green: 0.97, blue: 1.0),

    // Secondary (Teal) — lighter in dark mode
    secondary50: Color(red: 0.0, green: 0.28, blue: 0.32),
    secondary100: Color(red: 0.0, green: 0.39, blue: 0.45),
    secondary200: Color(red: 0.0, green: 0.51, blue: 0.59),
    secondary300: Color(red: 0.0, green: 0.62, blue: 0.71),
    secondary400: Color(red: 0.10, green: 0.74, blue: 0.83),
    secondary500: Color(red: 0.35, green: 0.82, blue: 0.88),
    secondary600: Color(red: 0.55, green: 0.88, blue: 0.92),
    secondary700: Color(red: 0.71, green: 0.93, blue: 0.96),
    secondary800: Color(red: 0.85, green: 0.97, blue: 0.98),
    secondary900: Color(red: 0.94, green: 0.99, blue: 0.99),

    // Semantic
    success: Color(red: 0.25, green: 0.85, blue: 0.50),
    warning: Color(red: 1.0, green: 0.75, blue: 0.20),
    error: Color(red: 1.0, green: 0.40, blue: 0.50),
    info: Color(red: 0.47, green: 0.71, blue: 1.0),

    // Surface
    background: Color(red: 0.08, green: 0.08, blue: 0.08),
    surface: Color(red: 0.12, green: 0.12, blue: 0.12),
    surfaceElevated: Color(red: 0.18, green: 0.18, blue: 0.18),
    border: Color(red: 0.26, green: 0.26, blue: 0.26),

    // Text
    textPrimary: Color(red: 0.96, green: 0.96, blue: 0.96),
    textSecondary: Color(red: 0.72, green: 0.72, blue: 0.72),
    textTertiary: Color(red: 0.45, green: 0.45, blue: 0.45),
    textInverse: Color(red: 0.08, green: 0.08, blue: 0.08),

    // Status
    statusConnected: Color(red: 0.25, green: 0.85, blue: 0.50),
    statusDisconnected: Color(red: 0.45, green: 0.45, blue: 0.45),
    statusPending: Color(red: 1.0, green: 0.75, blue: 0.20)
)
