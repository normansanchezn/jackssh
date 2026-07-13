import SwiftUI

/// A restrained Liquid Glass surface for grouped information and controls.
/// It reads colors from the theme environment and stays compact on mobile.
public struct DSGlassSurface<Content: View>: View {
    @Environment(\.jacksshTheme) private var theme
    private let content: Content
    private let tint: Color?

    public init(tint: Color? = nil, @ViewBuilder content: () -> Content) {
        self.tint = tint
        self.content = content()
    }

    public var body: some View {
        content
            .background((tint ?? theme.colors.surface).opacity(0.72), in: RoundedRectangle(cornerRadius: DSRadius.sm, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: DSRadius.sm, style: .continuous)
                    .fill(theme.colors.surfaceElevated.opacity(0.12))
                    .allowsHitTesting(false)
            }
            .overlay {
                RoundedRectangle(cornerRadius: DSRadius.sm, style: .continuous)
                    .stroke((tint ?? theme.colors.border).opacity(0.82), lineWidth: 1)
                    .allowsHitTesting(false)
            }
            .shadow(color: .black.opacity(0.22), radius: 18, x: 0, y: 10)
    }
}

public extension View {
    /// Applies the shared Liquid Glass treatment without requiring a wrapper view.
    func dsGlassSurface(tint: Color? = nil) -> some View {
        DSGlassSurface(tint: tint) {
            self
        }
    }
}
