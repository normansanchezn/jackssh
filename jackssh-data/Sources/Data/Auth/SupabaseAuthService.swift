import Foundation
import Domain
import Shared

/// Remote data source for Supabase Auth's HTTP API. It owns transport details
/// and API response models; repositories map those results to Domain entities.
public struct SupabaseAuthService: Sendable {
    private let supabaseURL: URL
    private let supabaseKey: String
    private let session: URLSession

    public init(supabaseURL: URL, supabaseKey: String, session: URLSession = .shared) {
        self.supabaseURL = supabaseURL
        self.supabaseKey = supabaseKey
        self.session = session
    }

    func signUp(email: String, password: String, displayName: String?) async throws -> SupabaseAuthSessionDTO? {
        let endpoint = endpoint(path: "signup")
        var body: [String: Any] = ["email": email, "password": password]
        if let displayName, !displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            body["data"] = ["display_name": displayName]
        }
        let data = try await post(endpoint: endpoint, body: body, successCodes: 200...201)
        return try JSONDecoder().decode(SupabaseSignUpResponseDTO.self, from: data).session
    }

    func signIn(email: String, password: String) async throws -> SupabaseAuthSessionDTO {
        let endpoint = endpoint(path: "token", queryItems: [URLQueryItem(name: "grant_type", value: "password")])
        let data = try await post(endpoint: endpoint, body: ["email": email, "password": password], successCodes: 200...200)
        return try JSONDecoder().decode(SupabaseTokenResponseDTO.self, from: data)
    }

    func refreshSession(refreshToken: String) async throws -> SupabaseAuthSessionDTO {
        let endpoint = endpoint(path: "token", queryItems: [URLQueryItem(name: "grant_type", value: "refresh_token")])
        let data = try await post(endpoint: endpoint, body: ["refresh_token": refreshToken], successCodes: 200...200)
        return try JSONDecoder().decode(SupabaseTokenResponseDTO.self, from: data)
    }

    func signOut(accessToken: String) async throws {
        let endpoint = endpoint(path: "logout")
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue(supabaseKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let (_, response) = try await session.data(for: request)
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
        guard (200...299).contains(statusCode) else { throw DomainError.unauthorized }
    }

    private func endpoint(path: String, queryItems: [URLQueryItem] = []) -> URL {
        var components = URLComponents(url: supabaseURL.appendingPathComponent("auth/v1/\(path)"), resolvingAgainstBaseURL: false)!
        components.queryItems = queryItems.isEmpty ? nil : queryItems
        return components.url!
    }

    private func post(
        endpoint: URL,
        body: [String: Any],
        successCodes: ClosedRange<Int>
    ) async throws -> Data {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(supabaseKey, forHTTPHeaderField: "apikey")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await session.data(for: request)
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
        AppLogger.logNetwork(method: "POST", url: endpoint.absoluteString, statusCode: statusCode)

        guard successCodes.contains(statusCode) else {
            AppLogger.logNetwork(method: "POST", url: endpoint.absoluteString, statusCode: statusCode, error: DomainError.unauthorized)
            throw DomainError.unauthorized
        }
        return data
    }
}

struct SupabaseUserDTO: Decodable, Sendable {
    let id: UUID
    let email: String
    let userMetadata: [String: String]?

    var displayName: String? {
        userMetadata?["display_name"] ?? userMetadata?["full_name"] ?? userMetadata?["name"]
    }

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case userMetadata = "user_metadata"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        email = try container.decode(String.self, forKey: .email)
        userMetadata = try? container.decode([String: String].self, forKey: .userMetadata)
    }
}

struct SupabaseAuthSessionDTO: Decodable, Sendable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int
    let user: SupabaseUserDTO

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
        case user
    }
}

private struct SupabaseSignUpResponseDTO: Decodable {
    let session: SupabaseAuthSessionDTO?
}

private typealias SupabaseTokenResponseDTO = SupabaseAuthSessionDTO
