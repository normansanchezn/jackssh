import Foundation

/// Authenticates a user through the configured identity provider.
public struct SignIn: Sendable {
    private let repository: AuthRepository

    public init(repository: AuthRepository) {
        self.repository = repository
    }

    public func callAsFunction(email: String, password: String) async throws -> User {
        try await repository.signIn(email: email, password: password)
    }
}

/// Creates a user account through the configured identity provider.
public struct SignUp: Sendable {
    private let repository: AuthRepository

    public init(repository: AuthRepository) {
        self.repository = repository
    }

    public func callAsFunction(email: String, password: String) async throws -> User {
        try await repository.signUp(email: email, password: password)
    }
}

/// Ends the current authenticated session.
public struct SignOut: Sendable {
    private let repository: AuthRepository

    public init(repository: AuthRepository) {
        self.repository = repository
    }

    public func callAsFunction() async throws {
        try await repository.signOut()
    }
}

/// Retrieves the user associated with the current authenticated session.
public struct LoadCurrentUser: Sendable {
    private let repository: AuthRepository

    public init(repository: AuthRepository) {
        self.repository = repository
    }

    public func callAsFunction() async throws -> User? {
        try await repository.getCurrentUser()
    }
}
