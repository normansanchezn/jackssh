import SwiftUI

/// Atom: rounded surface container. Uses a material background so it adapts to
/// light and dark automatically.
public struct DSCard<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
            .padding(DSSpacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: DSRadius.md, style: .continuous))
    }
}
