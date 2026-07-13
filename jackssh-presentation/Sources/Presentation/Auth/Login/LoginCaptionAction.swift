import SwiftUI
import DesignSystem

struct LoginCaptionAction: View {
    @Environment(\.jacksshTheme) private var theme
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(DSTypography.caption.weight(.semibold))
                .foregroundStyle(theme.colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DSSpacing.sm)
                .padding(.vertical, DSSpacing.xs)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }
}
