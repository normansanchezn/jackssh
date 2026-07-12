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
        Background(showGrid: true) {
            VStack(spacing: DSSpacing.lg) {
                HStack {
                    DSButton(
                        "",
                        icon: "chevron.left",
                        style: .text,
                        size: .small
                    ) {
                        onBack()
                    }
                    
                    Spacer()
                    
                    Text("Create Account")
                        .font(DSTypography.sectionTitle)
                    
                    Spacer()
                    
                    Color.clear.frame(width: 44)
                }
                .padding(DSSpacing.lg)

                VStack(spacing: DSSpacing.md) {
                    DSInput("Email", text: $viewModel.email)
                    DSInput("Password", text: $viewModel.password, isSecure: true)
                    DSInput("Confirm Password", text: $viewModel.confirmPassword, isSecure: true)
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
                        "Create Account",
                        icon: "person.badge.plus.fill",
                        style: .filled,
                        fullWidth: true,
                        isLoading: viewModel.isLoading
                    ) {
                        Task {
                            await viewModel.signup()
                            if case .authenticated = viewModel.authState {
                                onSuccess()
                            }
                        }
                    }
                }
                .padding(DSSpacing.lg)
            }
        }
    }
}

#Preview("Sign up") {
    SignUpView(viewModel: PreviewFixtures.authViewModel(), onSuccess: {}, onBack: {})
        .withJacksshThemeAutomatic()
}
