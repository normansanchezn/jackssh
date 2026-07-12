import SwiftUI

/// Theme-aware single-line input with a restrained Liquid Glass surface.
public struct DSInput: View {
    @Environment(\.jacksshTheme) private var theme
    private let label: String
    private let text: Binding<String>
    private let isSecure: Bool

    public init(_ label: String, text: Binding<String>, isSecure: Bool = false) {
        self.label = label
        self.text = text
        self.isSecure = isSecure
    }

    public var body: some View {
        Group {
            if isSecure {
                SecureField(label, text: text)
            } else {
                TextField(label, text: text)
            }
        }
        .textFieldStyle(.plain)
        .padding(DSSpacing.md)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: DSRadius.sm, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: DSRadius.sm, style: .continuous)
                .stroke(theme.colors.border.opacity(0.8), lineWidth: 1)
        }
    }
}
