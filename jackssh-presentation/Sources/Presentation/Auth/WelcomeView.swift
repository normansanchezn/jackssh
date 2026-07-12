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
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

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
                    Button {
                        onSignIn()
                    } label: {
                        Text("Sign In")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

                    Button {
                        onSignUp()
                    } label: {
                        Text("Create Account")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                .padding(DSSpacing.lg)
            }
        }
    }
}
