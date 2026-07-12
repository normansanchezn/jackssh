import Foundation

/// User account (extends Supabase auth.users).
public struct User: Equatable, Sendable {
    public let id: UUID
    public let email: String
    public let createdAt: Date

    public init(id: UUID, email: String, createdAt: Date = Date()) {
        self.id = id
        self.email = email
        self.createdAt = createdAt
    }
}

/// Auth session state.
public enum AuthState: Equatable, Sendable {
    case unauthenticated
    case authenticating
    case authenticated(User)
    case error(String)
}

/// Login/signup request.
public struct AuthCredentials: Equatable, Sendable {
    public let email: String
    public let password: String

    public init(email: String, password: String) {
        self.email = email
        self.password = password
    }
}
