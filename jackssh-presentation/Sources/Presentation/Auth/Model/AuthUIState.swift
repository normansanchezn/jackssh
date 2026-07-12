import Domain

public struct AuthUIState: Equatable {
    public var authState: AuthState = .unauthenticated
    public var email: String = ""
    public var password: String = ""
    public var confirmPassword: String = ""
    public var isLoading = false
    public var error: String?

    public init() {}
}
