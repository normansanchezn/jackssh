import SwiftUI
import DesignSystem

public struct AuthFlowView: View {
    @State private var authViewModel: AuthViewModel
    @State private var currentStep: AuthStep = .welcome

    enum AuthStep {
        case welcome
        case signIn
        case signUp
    }

    public init(authViewModel: AuthViewModel) {
        _authViewModel = State(initialValue: authViewModel)
    }

    public var body: some View {
        switch currentStep {
        case .welcome:
            WelcomeView(
                onSignIn: { currentStep = .signIn },
                onSignUp: { currentStep = .signUp }
            )
        case .signIn:
            LoginView(
                viewModel: authViewModel,
                onSuccess: { currentStep = .welcome },
                onSignUp: { currentStep = .signUp }
            )
        case .signUp:
            SignUpView(
                viewModel: authViewModel,
                onSuccess: { currentStep = .welcome },
                onBack: { currentStep = .welcome }
            )
        }
    }
}

#Preview("Authentication") {
    AuthFlowView(authViewModel: PreviewFixtures.authViewModel())
        .withJacksshThemeAutomatic()
}
