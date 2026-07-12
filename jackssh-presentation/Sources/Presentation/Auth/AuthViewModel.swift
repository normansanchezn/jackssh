import Foundation
import Observation
import Domain

@MainActor
@Observable
public final class AuthViewModel {
    public private(set) var authState: AuthState = .unauthenticated
    public var email: String = ""
    public var password: String = ""
    public var confirmPassword: String = ""
    public private(set) var isLoading = false
    public var error: String?

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
                authState = .authenticated(user)
            } else {
                authState = .unauthenticated
            }
        } catch {
            authState = .unauthenticated
        }
    }

    public func login() async {
        error = nil
        guard !email.isEmpty, !password.isEmpty else {
            error = "Email and password required"
            return
        }

        isLoading = true
        authState = .authenticating
        defer { isLoading = false }

        do {
            let user = try await signIn(email: email, password: password)
            authState = .authenticated(user)
        } catch {
            authState = .error(error.localizedDescription)
            self.error = error.localizedDescription
        }
    }

    public func signup() async {
        error = nil
        guard !email.isEmpty, !password.isEmpty else {
            error = "Email and password required"
            return
        }
        guard password == confirmPassword else {
            error = "Passwords do not match"
            return
        }

        isLoading = true
        authState = .authenticating
        defer { isLoading = false }

        do {
            let user = try await signUp(email: email, password: password)
            authState = .authenticated(user)
        } catch {
            authState = .error(error.localizedDescription)
            self.error = error.localizedDescription
        }
    }

    public func logout() async {
        do {
            try await signOut()
            authState = .unauthenticated
            email = ""
            password = ""
            confirmPassword = ""
        } catch {
            self.error = error.localizedDescription
        }
    }
}
