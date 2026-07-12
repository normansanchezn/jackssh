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

    private let signIn: SignIn
    private let signUp: SignUp
    private let signOut: SignOut
    private let loadCurrentUser: LoadCurrentUser

    public init(
        signIn: SignIn,
        signUp: SignUp,
        signOut: SignOut,
        loadCurrentUser: LoadCurrentUser
    ) {
        self.signIn = signIn
        self.signUp = signUp
        self.signOut = signOut
        self.loadCurrentUser = loadCurrentUser
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
            uiState.authState = .authenticated(user)
            effect = .authenticated(user)
        } catch {
            uiState.authState = .error(error.localizedDescription)
            uiState.error = error.localizedDescription
            effect = .showError(error.localizedDescription)
        }
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
            let user = try await signUp(email: email, password: password)
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
            uiState.password = ""
            uiState.confirmPassword = ""
            effect = .signedOut
        } catch {
            uiState.error = error.localizedDescription
            effect = .showError(error.localizedDescription)
        }
    }

    public func clearEffect() {
        effect = .none
    }
}
