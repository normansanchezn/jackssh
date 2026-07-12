public struct AuthFlowUIState: Equatable {
    public enum Step: Equatable {
        case welcome
        case signIn
        case signUp
    }

    public var currentStep: Step = .welcome

    public init() {}
}
