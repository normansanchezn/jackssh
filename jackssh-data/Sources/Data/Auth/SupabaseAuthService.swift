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

    func signUp(email: String, password: String) async throws -> SupabaseUserDTO {
        let endpoint = endpoint(path: "signup")
        let data = try await post(endpoint: endpoint, body: ["email": email, "password": password], successCodes: 200...201)
        return try JSONDecoder().decode(SupabaseSignUpResponseDTO.self, from: data).user
    }

    func signIn(email: String, password: String) async throws -> SupabaseUserDTO {
        let endpoint = endpoint(path: "token", queryItems: [URLQueryItem(name: "grant_type", value: "password")])
        let data = try await post(endpoint: endpoint, body: ["email": email, "password": password], successCodes: 200...200)
        return try JSONDecoder().decode(SupabaseTokenResponseDTO.self, from: data).user
    }

    private func endpoint(path: String, queryItems: [URLQueryItem] = []) -> URL {
        var components = URLComponents(url: supabaseURL.appendingPathComponent("auth/v1/\(path)"), resolvingAgainstBaseURL: false)!
        components.queryItems = queryItems.isEmpty ? nil : queryItems
        return components.url!
    }

    private func post(
        endpoint: URL,
        body: [String: String],
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
}

private struct SupabaseSignUpResponseDTO: Decodable {
    let user: SupabaseUserDTO
}

private struct SupabaseTokenResponseDTO: Decodable {
    let user: SupabaseUserDTO
}
