import SwiftUI
import DesignSystem

public struct WelcomeView: View {
    let onSignIn: () -> Void
    let onSignUp: () -> Void

    public init(onSignIn: @escaping () -> Void, onSignUp: @escaping () -> Void) {
        self.onSignIn = onSignIn
        self.onSignUp = onSignUp
    }

    public var body: some View {
        _WelcomeContent(onSignIn: onSignIn, onSignUp: onSignUp)
    }
}

struct _WelcomeContent: View {
    @Environment(\.jacksshTheme) var theme
    let onSignIn: () -> Void
    let onSignUp: () -> Void

    var body: some View {
        ZStack {
            theme.colors.background.ignoresSafeArea()

            VStack(spacing: DSSpacing.lg) {
                Spacer()

                VStack(spacing: DSSpacing.md) {
                    Image(systemName: "terminal.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(.blue)

                    Text("Welcome to JackSsh")
                        .font(DSTypography.screenTitle)
                        .multilineTextAlignment(.center)

                    Text("Manage your SSH hosts and VPS infrastructure from your iOS device")
                        .font(DSTypography.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(DSSpacing.lg)

                Spacer()

                VStack(spacing: DSSpacing.md) {
                    DSButton(
                        "Sign In",
                        icon: "arrow.right.circle.fill",
                        style: .filled,
                        fullWidth: true
                    ) {
                        onSignIn()
                    }

                    DSButton(
                        "Create Account",
                        icon: "person.badge.plus",
                        style: .outline,
                        fullWidth: true
                    ) {
                        onSignUp()
                    }
                }
                .padding(DSSpacing.lg)
            }
        }
    }
}

#Preview("Welcome") {
    WelcomeView(onSignIn: {}, onSignUp: {})
        .withJacksshThemeAutomatic()
}
