import Foundation
import Observation
import Domain

@MainActor
@Observable
public final class AuthViewModel {
    public private(set) var uiState = AuthUIState()
    public private(set) var effect: AuthEffect = .none

    public var authState: AuthState { uiState.authState }
    public var email: String {
        get { uiState.email }
        set { uiState.email = newValue }
    }
    public var displayName: String {
        get { uiState.displayName }
        set { uiState.displayName = newValue }
    }
    public var password: String {
        get { uiState.password }
        set { uiState.password = newValue }
    }
    public var confirmPassword: String {
        get { uiState.confirmPassword }
        set { uiState.confirmPassword = newValue }
    }
    public var isLoading: Bool { uiState.isLoading }
    public var error: String? {
        get { uiState.error }
        set { uiState.error = newValue }
    }
    public var biometricAvailability: BiometricLoginAvailability { uiState.biometricAvailability }
    public var shouldOfferBiometricEnrollment: Bool { uiState.shouldOfferBiometricEnrollment }

    private let signIn: SignIn
    private let signUp: SignUp
    private let signOut: SignOut
    private let loadCurrentUser: LoadCurrentUser
    private let loadBiometricLoginAvailability: LoadBiometricLoginAvailability?
    private let enableBiometricLogin: EnableBiometricLogin?
    private let loadBiometricLoginCredentials: LoadBiometricLoginCredentials?
    private var pendingAuthenticatedUser: User?

    public init(
        signIn: SignIn,
        signUp: SignUp,
        signOut: SignOut,
        loadCurrentUser: LoadCurrentUser,
        loadBiometricLoginAvailability: LoadBiometricLoginAvailability? = nil,
        enableBiometricLogin: EnableBiometricLogin? = nil,
        loadBiometricLoginCredentials: LoadBiometricLoginCredentials? = nil
    ) {
        self.signIn = signIn
        self.signUp = signUp
        self.signOut = signOut
        self.loadCurrentUser = loadCurrentUser
        self.loadBiometricLoginAvailability = loadBiometricLoginAvailability
        self.enableBiometricLogin = enableBiometricLogin
        self.loadBiometricLoginCredentials = loadBiometricLoginCredentials
    }

    public func loadBiometricState() async {
        guard let loadBiometricLoginAvailability else { return }
        uiState.biometricAvailability = await loadBiometricLoginAvailability()
    }

    public func checkCurrentUser() async {
        do {
            if let user = try await loadCurrentUser() {
                uiState.authState = .authenticated(user)
                effect = .authenticated(user)
            } else {
                uiState.authState = .unauthenticated
            }
        } catch {
            uiState.authState = .unauthenticated
        }
    }

    public func login() async {
        uiState.error = nil
        guard !email.isEmpty, !password.isEmpty else {
            uiState.error = "Email and password required"
            effect = .showError("Email and password required")
            return
        }

        uiState.isLoading = true
        uiState.authState = .authenticating
        defer { uiState.isLoading = false }

        do {
            let user = try await signIn(email: email, password: password)
            if await shouldRequestBiometricEnrollment() {
                pendingAuthenticatedUser = user
                uiState.authState = .unauthenticated
                uiState.shouldOfferBiometricEnrollment = true
                effect = .requestBiometricEnrollment(uiState.biometricAvailability.biometryName)
            } else {
                completeAuthentication(with: user)
            }
        } catch {
            uiState.authState = .error(error.localizedDescription)
            uiState.error = error.localizedDescription
            effect = .showError(error.localizedDescription)
        }
    }

    public func loginWithBiometrics() async {
        guard let loadBiometricLoginCredentials else {
            uiState.error = "Biometric login is not configured"
            effect = .showError("Biometric login is not configured")
            return
        }

        uiState.error = nil
        uiState.isLoading = true
        uiState.authState = .authenticating
        defer { uiState.isLoading = false }

        do {
            let credentials = try await loadBiometricLoginCredentials()
            let user = try await signIn(email: credentials.email, password: credentials.password)
            uiState.email = credentials.email
            uiState.password = ""
            uiState.authState = .authenticated(user)
            effect = .authenticated(user)
        } catch {
            uiState.authState = .error(error.localizedDescription)
            uiState.error = error.localizedDescription
            effect = .showError(error.localizedDescription)
        }
    }

    public func enableBiometricLoginForCurrentCredentials() async {
        guard let enableBiometricLogin else {
            uiState.shouldOfferBiometricEnrollment = false
            return
        }
        do {
            try await enableBiometricLogin(email: email, password: password)
            uiState.shouldOfferBiometricEnrollment = false
            await loadBiometricState()
            completePendingAuthentication()
        } catch {
            uiState.shouldOfferBiometricEnrollment = false
            uiState.error = "Couldn’t enable biometric login"
            effect = .showError("Couldn’t enable biometric login")
            completePendingAuthentication()
        }
    }

    public func dismissBiometricEnrollmentOffer() {
        uiState.shouldOfferBiometricEnrollment = false
        completePendingAuthentication()
    }

    public func signup() async {
        uiState.error = nil
        guard !email.isEmpty, !password.isEmpty else {
            uiState.error = "Email and password required"
            effect = .showError("Email and password required")
            return
        }
        guard password == confirmPassword else {
            uiState.error = "Passwords do not match"
            effect = .showError("Passwords do not match")
            return
        }

        uiState.isLoading = true
        uiState.authState = .authenticating
        defer { uiState.isLoading = false }

        do {
            let user = try await signUp(email: email, password: password, displayName: displayName.trimmedNonEmpty)
            uiState.authState = .authenticated(user)
            effect = .authenticated(user)
        } catch {
            uiState.authState = .error(error.localizedDescription)
            uiState.error = error.localizedDescription
            effect = .showError(error.localizedDescription)
        }
    }

    public func logout() async {
        do {
            try await signOut()
            uiState.authState = .unauthenticated
            uiState.email = ""
            uiState.displayName = ""
            uiState.password = ""
            uiState.confirmPassword = ""
            effect = .signedOut
            await loadBiometricState()
        } catch {
            uiState.error = error.localizedDescription
            effect = .showError(error.localizedDescription)
        }
    }

    public func clearEffect() {
        effect = .none
    }

    private func shouldRequestBiometricEnrollment() async -> Bool {
        guard let loadBiometricLoginAvailability else { return false }
        let availability = await loadBiometricLoginAvailability()
        uiState.biometricAvailability = availability
        return availability.isAvailable && !availability.isEnabled
    }

    private func completePendingAuthentication() {
        guard let pendingAuthenticatedUser else { return }
        self.pendingAuthenticatedUser = nil
        completeAuthentication(with: pendingAuthenticatedUser)
    }

    private func completeAuthentication(with user: User) {
        uiState.authState = .authenticated(user)
        effect = .authenticated(user)
    }
}

private extension String {
    var trimmedNonEmpty: String? {
        let value = trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? nil : value
    }
}
