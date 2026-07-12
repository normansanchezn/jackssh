import Observation

@MainActor
@Observable
public final class AuthFlowViewModel {
    public private(set) var uiState = AuthFlowUIState()
    public private(set) var effect: AuthFlowEffect = .none

    public init() {}

    public func showWelcome() {
        setStep(.welcome)
    }

    public func showSignIn() {
        setStep(.signIn)
    }

    public func showSignUp() {
        setStep(.signUp)
    }

    public func clearEffect() {
        effect = .none
    }

    private func setStep(_ step: AuthFlowUIState.Step) {
        uiState.currentStep = step
        effect = .stepChanged(step)
    }
}
