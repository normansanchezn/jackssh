import SwiftUI

/// Compact icon, label, and value row for session or configuration details.
public struct DSDetailRow: View {
    @Environment(\.jacksshTheme) private var theme
    private let label: String
    private let value: String
    private let symbol: String

    public init(label: String, value: String, symbol: String) {
        self.label = label
        self.value = value
        self.symbol = symbol
    }

    public var body: some View {
        HStack(spacing: DSSpacing.sm) {
            Image(systemName: symbol)
                .foregroundStyle(theme.colors.textTertiary)
                .frame(width: 18)
            Text(label)
                .font(DSTypography.caption)
                .foregroundStyle(theme.colors.textSecondary)
            Spacer(minLength: DSSpacing.sm)
            Text(value)
                .font(.system(.footnote, design: .monospaced))
                .foregroundStyle(theme.colors.textPrimary)
                .lineLimit(1)
                .truncationMode(.middle)
        }
        .padding(.vertical, DSSpacing.md)
    }
}
