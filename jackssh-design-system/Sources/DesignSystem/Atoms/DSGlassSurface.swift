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
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: DSRadius.sm, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: DSRadius.sm, style: .continuous)
                    .fill((tint ?? theme.colors.surface).opacity(0.10))
            }
            .overlay {
                RoundedRectangle(cornerRadius: DSRadius.sm, style: .continuous)
                    .stroke((tint ?? theme.colors.border).opacity(0.70), lineWidth: 1)
            }
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
