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
