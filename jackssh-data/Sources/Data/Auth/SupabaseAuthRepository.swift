import Foundation
import Domain

/// Supabase Auth implementation.
public actor SupabaseAuthRepository: AuthRepository {
    private let supabaseURL: URL
    private let supabaseKey: String

    public init(supabaseURL: URL, supabaseKey: String) {
        self.supabaseURL = supabaseURL
        self.supabaseKey = supabaseKey
    }

    public func signUp(email: String, password: String) async throws -> User {
        #if DEBUG
        print("[SupabaseAuth] 📝 Sign up attempt: \(email)")
        #endif

        let endpoint = supabaseURL
            .appendingPathComponent("auth")
            .appendingPathComponent("v1")
            .appendingPathComponent("signup")

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(supabaseKey, forHTTPHeaderField: "apikey")

        let body = ["email": email, "password": password]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, (200...201).contains(httpResponse.statusCode) else {
            #if DEBUG
            let errorStr = String(data: data, encoding: .utf8) ?? "unknown"
            print("[SupabaseAuth] ❌ Sign up failed: \(errorStr)")
            #endif
            throw DomainError.unauthorized
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let authResponse = try decoder.decode(AuthResponse.self, from: data)

        #if DEBUG
        print("[SupabaseAuth] ✅ Sign up successful: \(authResponse.user.id)")
        #endif

        return User(id: authResponse.user.id, email: authResponse.user.email)
    }

    public func signIn(email: String, password: String) async throws -> User {
        #if DEBUG
        print("[SupabaseAuth] 🔑 Sign in attempt: \(email)")
        #endif

        let endpoint = supabaseURL
            .appendingPathComponent("auth")
            .appendingPathComponent("v1")
            .appendingPathComponent("token")
            .appendingQueryItem("grant_type", value: "password")

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(supabaseKey, forHTTPHeaderField: "apikey")

        let body = ["email": email, "password": password]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            #if DEBUG
            let errorStr = String(data: data, encoding: .utf8) ?? "unknown"
            print("[SupabaseAuth] ❌ Sign in failed: \(errorStr)")
            #endif
            throw DomainError.unauthorized
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let tokenResponse = try decoder.decode(TokenResponse.self, from: data)

        #if DEBUG
        print("[SupabaseAuth] ✅ Sign in successful")
        #endif

        return User(id: tokenResponse.user.id, email: tokenResponse.user.email)
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

// MARK: - Response Models

private struct AuthResponse: Codable {
    struct UserData: Codable {
        let id: UUID
        let email: String
    }

    let user: UserData
    let session: SessionData?
}

private struct TokenResponse: Codable {
    struct UserData: Codable {
        let id: UUID
        let email: String
    }

    let user: UserData
    let access_token: String
}

private struct SessionData: Codable {
    let access_token: String
    let refresh_token: String
}

// MARK: - URL Helper

extension URL {
    fileprivate func appendingQueryItem(_ name: String, value: String) -> URL {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: false)!
        var queryItems = components.queryItems ?? []
        queryItems.append(URLQueryItem(name: name, value: value))
        components.queryItems = queryItems
        return components.url!
    }
}
