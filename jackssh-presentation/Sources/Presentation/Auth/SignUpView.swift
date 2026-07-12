import SwiftUI
import DesignSystem

public struct SignUpView: View {
    @State private var viewModel: AuthViewModel
    @Environment(\.jacksshTheme) var theme
    let onSuccess: () -> Void
    let onBack: () -> Void

    public init(viewModel: AuthViewModel, onSuccess: @escaping () -> Void, onBack: @escaping () -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onSuccess = onSuccess
        self.onBack = onBack
    }

    public var body: some View {
        ZStack {
            theme.colors.background.ignoresSafeArea()

            VStack(spacing: DSSpacing.lg) {
                HStack {
                    Button {
                        onBack()
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                    Spacer()
                    Text("Create Account")
                        .font(DSTypography.sectionTitle)
                    Spacer()
                    Color.clear.frame(width: 44)
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

                    SecureField("Confirm Password", text: $viewModel.confirmPassword)
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
                            await viewModel.signup()
                            if case .authenticated = viewModel.authState {
                                onSuccess()
                            }
                        }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Sign Up")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.isLoading)
                }
                .padding(DSSpacing.lg)
            }
        }
    }
}
