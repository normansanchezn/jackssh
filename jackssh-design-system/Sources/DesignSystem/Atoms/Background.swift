import SwiftUI

public struct Background<Content: View>: View {
    @Environment(\.jacksshTheme) var theme
    private let content: () -> Content

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        ZStack {
            theme.colors.background
                .ignoresSafeArea()

            content()
        }
    }
}

public struct BackgroundElevated<Content: View>: View {
    @Environment(\.jacksshTheme) var theme
    private let content: () -> Content

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        ZStack {
            theme.colors.surfaceElevated
                .ignoresSafeArea()

            content()
        }
    }
}
