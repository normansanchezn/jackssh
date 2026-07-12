import SwiftUI

public struct JacksshTheme: Sendable {
    public let colors: DSColorTokens
    public let spacing = DSSpacing.self
    public let radius = DSRadius.self
    public let typography = DSTypography.self

    init(colorScheme: ColorScheme?) {
        if colorScheme == .dark {
            self.colors = darkColorTokens
        } else {
            self.colors = lightColorTokens
        }
    }
}

struct JacksshThemeKey: EnvironmentKey {
    static let defaultValue: JacksshTheme = JacksshTheme(colorScheme: .light)
}

public extension EnvironmentValues {
    var jacksshTheme: JacksshTheme {
        get { self[JacksshThemeKey.self] }
        set { self[JacksshThemeKey.self] = newValue }
    }
}

public struct ThemeContainer<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
            .environment(\.jacksshTheme, JacksshTheme(colorScheme: colorScheme))
    }
}

public extension View {
    func withJacksshTheme() -> some View {
        environment(\.jacksshTheme, JacksshTheme(colorScheme: .light))
    }

    func withJacksshThemeAutomatic() -> some View {
        modifier(AutomaticThemeModifier())
    }
}

struct AutomaticThemeModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        content
            .environment(\.jacksshTheme, JacksshTheme(colorScheme: colorScheme))
    }
}
