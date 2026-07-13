import Foundation
import Domain
import Shared
/// `AuthRepository` implementation backed by Supabase's remote data source.
public actor SupabaseAuthRepository: AuthRepository {
    private static let sessionKey = "supabase.auth.session"
    private let service: SupabaseAuthService
    private let secureStore: SecretStore

    public init(service: SupabaseAuthService, secureStore: SecretStore) {
        self.service = service
        self.secureStore = secureStore
    }

    public func signUp(email: String, password: String, displayName: String?) async throws -> User {
        AppLogger.logAuth(action: "SignUp", email: email, success: false)
        guard let session = try await service.signUp(email: email, password: password, displayName: displayName) else {
            throw DomainError.unauthorized
        }
        try await persist(session)

        AppLogger.logAuth(action: "SignUp", email: email, success: true)
        return User(id: session.user.id, email: session.user.email, displayName: session.user.displayName)
    }

    public func signIn(email: String, password: String) async throws -> User {
        #if DEBUG
        print("[SupabaseAuth] 🔑 Sign in attempt: \(email)")
        #endif

        let session = try await service.signIn(email: email, password: password)
        try await persist(session)

        #if DEBUG
        print("[SupabaseAuth] ✅ Sign in successful")
        #endif

        return User(id: session.user.id, email: session.user.email, displayName: session.user.displayName)
    }

    public func signOut() async throws {
        let session = try await storedSession()
        if let session { try? await service.signOut(accessToken: session.accessToken) }
        try await secureStore.removeSecret(for: Self.sessionKey)
    }

    public func getCurrentUser() async throws -> User? {
        guard let session = try await currentStoredSession() else { return nil }
        return User(id: session.userID, email: session.email, displayName: session.displayName)
    }

    public func currentSessionContext() async throws -> SupabaseSessionContext? {
        guard let session = try await currentStoredSession() else { return nil }
        return SupabaseSessionContext(accessToken: session.accessToken, userID: session.userID)
    }

    public func resetPassword(email: String) async throws {
        #if DEBUG
        print("[SupabaseAuth] 🔄 Reset password: \(email)")
        #endif
    }

    private func persist(_ session: SupabaseAuthSessionDTO) async throws {
        let data = try JSONEncoder().encode(StoredSession(session))
        try await secureStore.setSecret(data, for: Self.sessionKey)
    }

    private func storedSession() async throws -> StoredSession? {
        guard let data = try await secureStore.secret(for: Self.sessionKey) else { return nil }
        do {
            return try JSONDecoder().decode(StoredSession.self, from: data)
        } catch {
            try await secureStore.removeSecret(for: Self.sessionKey)
            return nil
        }
    }

    private func currentStoredSession() async throws -> StoredSession? {
        guard var session = try await storedSession() else { return nil }
        if session.expiresAt <= Date().addingTimeInterval(60) {
            do {
                let refreshed = try await service.refreshSession(refreshToken: session.refreshToken)
                try await persist(refreshed)
                session = StoredSession(refreshed)
            } catch {
                // Keep the local session when refresh cannot run (for example
                // while the app resumes without a network connection). A later
                // foreground launch can retry without forcing an unexpected logout.
            }
        }
        return session
    }
}

public struct SupabaseSessionContext: Sendable {
    public let accessToken: String
    public let userID: UUID

    public init(accessToken: String, userID: UUID) {
        self.accessToken = accessToken
        self.userID = userID
    }
}

private struct StoredSession: Codable, Sendable {
    let accessToken: String
    let refreshToken: String
    let expiresAt: Date
    let userID: UUID
    let email: String
    let displayName: String?

    init(_ session: SupabaseAuthSessionDTO, now: Date = Date()) {
        accessToken = session.accessToken
        refreshToken = session.refreshToken
        expiresAt = now.addingTimeInterval(TimeInterval(session.expiresIn))
        userID = session.user.id
        email = session.user.email
        displayName = session.user.displayName
    }
}
