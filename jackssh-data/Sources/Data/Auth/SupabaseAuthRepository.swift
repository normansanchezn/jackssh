import Foundation
import Domain
import Shared
/// `AuthRepository` implementation backed by Supabase's remote data source.
public actor SupabaseAuthRepository: AuthRepository {
    private let service: SupabaseAuthService

    public init(service: SupabaseAuthService) {
        self.service = service
    }

    public func signUp(email: String, password: String) async throws -> User {
        AppLogger.logAuth(action: "SignUp", email: email, success: false)
        let user = try await service.signUp(email: email, password: password)

        AppLogger.logAuth(action: "SignUp", email: email, success: true)
        return User(id: user.id, email: user.email)
    }

    public func signIn(email: String, password: String) async throws -> User {
        #if DEBUG
        print("[SupabaseAuth] 🔑 Sign in attempt: \(email)")
        #endif

        let user = try await service.signIn(email: email, password: password)

        #if DEBUG
        print("[SupabaseAuth] ✅ Sign in successful")
        #endif

        return User(id: user.id, email: user.email)
    }

    public func signOut() async throws {
        #if DEBUG
        print("[SupabaseAuth] 🚪 Sign out")
        #endif
    }

    public func getCurrentUser() async throws -> User? {
        #if DEBUG
        print("[SupabaseAuth] 👤 Get current user")
        #endif
        return nil // Would check session token
    }

    public func resetPassword(email: String) async throws {
        #if DEBUG
        print("[SupabaseAuth] 🔄 Reset password: \(email)")
        #endif
    }
}
