#if os(iOS)
import SwiftTerm
import UIKit

/// Termius-inspired dark theme for the terminal emulator.
/// A 16-entry ANSI palette plus background/foreground/cursor colors.
///
@MainActor
enum TerminalTheme {
    /// SwiftTerm uses 16-bit channels (0...65535) per component.
    private static func c(_ r: UInt16, _ g: UInt16, _ b: UInt16) -> SwiftTerm.Color {
        SwiftTerm.Color(red: r * 257, green: g * 257, blue: b * 257)
    }

    /// The 16 ANSI colors (normal 0-7, bright 8-15), tuned to Termius' dark look.
    static let ansiColors: [SwiftTerm.Color] = [
        c(0x2B, 0x2E, 0x33), // black
        c(0xE0, 0x6C, 0x75), // red
        c(0x98, 0xC3, 0x79), // green
        c(0xE5, 0xC0, 0x7B), // yellow
        c(0x61, 0xAF, 0xEF), // blue
        c(0xC6, 0x78, 0xDD), // magenta
        c(0x56, 0xB6, 0xC2), // cyan
        c(0xAB, 0xB2, 0xBF), // white
        c(0x5C, 0x63, 0x70), // bright black
        c(0xE0, 0x6C, 0x75), // bright red
        c(0x98, 0xC3, 0x79), // bright green
        c(0xE5, 0xC0, 0x7B), // bright yellow
        c(0x61, 0xAF, 0xEF), // bright blue
        c(0xC6, 0x78, 0xDD), // bright magenta
        c(0x56, 0xB6, 0xC2), // bright cyan
        c(0xFF, 0xFF, 0xFF), // bright white
    ]

    static let background = UIColor(red: 0x02/255, green: 0x05/255, blue: 0x0B/255, alpha: 1)
    static let foreground = UIColor(red: 0xB5/255, green: 0xC2/255, blue: 0xCA/255, alpha: 1)
    static let cursor = UIColor(red: 0x23/255, green: 0xD5/255, blue: 0xEA/255, alpha: 1)
    static let selection = UIColor(red: 0x13/255, green: 0x31/255, blue: 0x3C/255, alpha: 1)

    /// Preferred monospace font. JetBrains Mono is used when its .ttf is bundled
    /// in the app target; otherwise we fall back to the system monospaced face,
    /// which is metrically stable and ships with iOS.
    static func font(size: CGFloat = 13) -> UIFont {
        UIFont(name: "JetBrainsMono-Regular", size: size)
            ?? UIFont.monospacedSystemFont(ofSize: size, weight: .regular)
    }
}

#endif
