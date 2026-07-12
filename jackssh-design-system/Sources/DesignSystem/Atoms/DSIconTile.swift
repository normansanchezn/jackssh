import SwiftUI

/// Fixed-size semantic icon tile used in operational cards and list rows.
public struct DSIconTile: View {
    @Environment(\.jacksshTheme) private var theme
    private let symbol: String
    private let tint: Color?
    private let size: CGFloat

    public init(symbol: String, tint: Color? = nil, size: CGFloat = 42) {
        self.symbol = symbol
        self.tint = tint
        self.size = size
    }

    public var body: some View {
        Image(systemName: symbol)
            .font(.system(size: size * 0.40, weight: .semibold))
            .foregroundStyle(resolvedTint)
            .frame(width: size, height: size)
            .background(resolvedTint.opacity(0.14), in: RoundedRectangle(cornerRadius: DSRadius.sm, style: .continuous))
            .accessibilityHidden(true)
    }

    private var resolvedTint: Color {
        tint ?? theme.colors.primary600
    }
}
