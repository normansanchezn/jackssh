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
        ZStack {
            theme.colors.background.ignoresSafeArea()

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
                        .background(theme.colors.surface)
                        .cornerRadius(DSRadius.sm)
                        .border(theme.colors.border)

                    SecureField("Password", text: $viewModel.password)
                        .padding(DSSpacing.md)
                        .background(theme.colors.surface)
                        .cornerRadius(DSRadius.sm)
                        .border(theme.colors.border)
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
                    Button {
                        Task {
                            await viewModel.login()
                            if case .authenticated = viewModel.authState {
                                onSuccess()
                            }
                        }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Sign In")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.isLoading)

                    Button {
                        onSignUp()
                    } label: {
                        Text("Don't have an account? Sign Up")
                            .font(DSTypography.caption)
                    }
                    .buttonStyle(.plain)
                }
                .padding(DSSpacing.lg)
            }
        }
    }
}
