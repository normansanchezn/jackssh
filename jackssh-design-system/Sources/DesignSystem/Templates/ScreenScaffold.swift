import SwiftUI

/// Template: consistent screen shell — large title plus a scrolling content
/// column with standard insets. Feature screens compose their content inside.
public struct ScreenScaffold<Content: View>: View {
    private let title: String
    private let content: Content

    public init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.lg) {
                content
            }
            .padding(DSSpacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle(title)
    }
}
