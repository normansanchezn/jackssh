import SwiftUI
import DesignSystem
import Domain

public struct LoginView: View {
    @State private var viewModel: AuthViewModel
    @Environment(\.jacksshTheme) var theme
    let onSuccess: () -> Void
    let onSignUp: () -> Void

    public init(viewModel: AuthViewModel, onSuccess: @escaping () -> Void, onSignUp: @escaping () -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onSuccess = onSuccess
        self.onSignUp = onSignUp
    }

    public var body: some View {
        Background {
            content()
        }
    }
    
    private func content() -> some View {
        VStack(spacing: DSSpacing.lg) {
            VStack(spacing: DSSpacing.md) {
                Image(systemName: "terminal.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.blue)

                Text("Sign In")
                    .font(DSTypography.sectionTitle)
            }
            .padding(DSSpacing.lg)

            VStack(spacing: DSSpacing.md) {
                TextField("Email", text: $viewModel.email)
                    .padding(DSSpacing.md)
                    .background(theme.colors.surfaceElevated.opacity(0.8))
                    .cornerRadius(DSRadius.sm)
                    .overlay(
                        RoundedRectangle(cornerRadius: DSRadius.sm)
                            .stroke(theme.colors.border, lineWidth: 1)
                    )

                SecureField("Password", text: $viewModel.password)
                    .padding(DSSpacing.md)
                    .background(theme.colors.surfaceElevated.opacity(0.8))
                    .cornerRadius(DSRadius.sm)
                    .overlay(
                        RoundedRectangle(cornerRadius: DSRadius.sm)
                            .stroke(theme.colors.border, lineWidth: 1)
                    )
            }
            .padding(DSSpacing.lg)

            if let error = viewModel.error {
                Text(error)
                    .font(DSTypography.caption)
                    .foregroundStyle(.red)
                    .padding(DSSpacing.md)
            }

            Spacer()

            VStack(spacing: DSSpacing.md) {
                DSButton(
                    "Sign In",
                    icon: "arrow.right.circle.fill",
                    style: .filled,
                    fullWidth: true,
                    isLoading: viewModel.isLoading
                ) {
                    Task {
                        await viewModel.login()
                        if case .authenticated = viewModel.authState {
                            onSuccess()
                        }
                    }
                }

                DSButton(
                    "Don't have an account? Sign Up",
                    style: .text
                ) {
                    onSignUp()
                }
            }
            .padding(DSSpacing.lg)
        }
    }
}
