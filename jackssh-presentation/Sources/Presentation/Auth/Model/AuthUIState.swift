import Domain

public struct AuthUIState: Equatable {
    public var authState: AuthState = .unauthenticated
    public var displayName: String = ""
    public var email: String = ""
    public var password: String = ""
    public var confirmPassword: String = ""
    public var isLoading = false
    public var error: String?
    public var biometricAvailability = BiometricLoginAvailability(
        isAvailable: false,
        isEnabled: false,
        biometryName: "biometrics",
        email: nil
    )
    public var shouldOfferBiometricEnrollment = false

    public init() {}
}
