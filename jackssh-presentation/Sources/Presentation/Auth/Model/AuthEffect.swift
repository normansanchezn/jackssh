import Domain

public enum AuthEffect: Equatable {
    case none
    case authenticated(User)
    case signedOut
    case showError(String)
    case requestBiometricEnrollment(String)
}
