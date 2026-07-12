import SwiftUI
import DesignSystem

public struct AuthFlowView: View {
    @State private var authViewModel: AuthViewModel
    @State private var viewModel = AuthFlowViewModel()

    public init(authViewModel: AuthViewModel) {
        _authViewModel = State(initialValue: authViewModel)
    }

    public var body: some View {
        switch viewModel.uiState.currentStep {
        case .welcome:
            WelcomeView(
                onSignIn: { viewModel.showSignIn() },
                onSignUp: { viewModel.showSignUp() }
            )
        case .signIn:
            LoginView(
                viewModel: authViewModel,
                onSuccess: { viewModel.showWelcome() },
                onSignUp: { viewModel.showSignUp() }
            )
        case .signUp:
            SignUpView(
                viewModel: authViewModel,
                onSuccess: { viewModel.showWelcome() },
                onBack: { viewModel.showWelcome() }
            )
        }
    }
}

#Preview("Authentication") {
    AuthFlowView(authViewModel: PreviewFixtures.authViewModel())
        .withJacksshThemeAutomatic()
}
