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
        AuthAdaptiveLayout(
            title: "Create Account",
            subtitle: "Set up your JackSSH identity for host sync and private access.",
            symbol: "person.badge.plus"
        ) {
            VStack(alignment: .leading, spacing: DSSpacing.lg) {
                Button {
                    onBack()
                } label: {
                    Label("Back", systemImage: "chevron.left")
                        .font(DSTypography.caption.weight(.semibold))
                }
                .buttonStyle(.plain)
                .foregroundStyle(theme.colors.primary600)

                VStack(spacing: DSSpacing.md) {
                    DSInput("Name", text: $viewModel.displayName)
                    DSInput("Email", text: $viewModel.email)
                    DSInput("Password", text: $viewModel.password, isSecure: true)
                    DSInput("Confirm Password", text: $viewModel.confirmPassword, isSecure: true)
                }

                if let error = viewModel.error {
                    Text(error)
                        .font(DSTypography.caption)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

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
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview("Sign up") {
    SignUpView(viewModel: PreviewFixtures.authViewModel(), onSuccess: {}, onBack: {})
        .withJacksshThemeAutomatic()
}
