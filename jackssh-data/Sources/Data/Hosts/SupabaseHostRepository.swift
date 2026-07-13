import Foundation
import Domain
import Shared

public protocol SupabaseSessionProviding: Sendable {
    func currentSessionContext() async throws -> SupabaseSessionContext?
}

extension SupabaseAuthRepository: SupabaseSessionProviding {}

/// Supabase REST-backed host repository. It persists non-sensitive host metadata
/// in `public.hosts`; passwords and private keys stay in the local Keychain.
public actor SupabaseHostRepository: HostRepository {
    private let supabaseURL: URL
    private let supabaseKey: String
    private let sessionProvider: SupabaseSessionProviding
    private let urlSession: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    public init(
        supabaseURL: URL,
        supabaseKey: String,
        sessionProvider: SupabaseSessionProviding,
        urlSession: URLSession = .shared
    ) {
        self.supabaseURL = supabaseURL
        self.supabaseKey = supabaseKey
        self.sessionProvider = sessionProvider
        self.urlSession = urlSession

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        self.encoder = encoder
    }

    public func all() async throws -> [Domain.Host] {
        let endpoint = restEndpoint(queryItems: [
            URLQueryItem(
                name: "select",
                value: "id,user_id,name,hostname,port,username,private_address,tags,auth_method,ssh_key_id,openclaw_host,openclaw_port,openclaw_scheme,openclaw_base_path,favorite_remote_path,is_favorite,last_successful_connection"
            ),
            URLQueryItem(name: "order", value: "name.asc")
        ])

        var request = try await authenticatedRequest(url: endpoint)
        request.httpMethod = "GET"

        let data = try await perform(request, successCodes: 200...200)
        return try decoder.decode([SupabaseHostDTO].self, from: data).map(\.asDomain)
    }

    public func host(id: UUID) async throws -> Domain.Host? {
        let endpoint = restEndpoint(queryItems: [
            URLQueryItem(
                name: "select",
                value: "id,user_id,name,hostname,port,username,private_address,tags,auth_method,ssh_key_id,openclaw_host,openclaw_port,openclaw_scheme,openclaw_base_path,favorite_remote_path,is_favorite,last_successful_connection"
            ),
            URLQueryItem(name: "id", value: "eq.\(id.uuidString)")
        ])

        var request = try await authenticatedRequest(url: endpoint)
        request.httpMethod = "GET"

        let data = try await perform(request, successCodes: 200...200)
        return try decoder.decode([SupabaseHostDTO].self, from: data).first?.asDomain
    }

    public func save(_ host: Domain.Host) async throws {
        let context = try await requireSession()
        let endpoint = restEndpoint(queryItems: [URLQueryItem(name: "on_conflict", value: "id")])

        var request = try await authenticatedRequest(url: endpoint, context: context)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("resolution=merge-duplicates,return=minimal", forHTTPHeaderField: "Prefer")
        request.httpBody = try encoder.encode(SupabaseHostDTO(host: host, userID: context.userID))

        _ = try await perform(request, successCodes: 200...201)
    }

    public func delete(id: UUID) async throws {
        let endpoint = restEndpoint(queryItems: [URLQueryItem(name: "id", value: "eq.\(id.uuidString)")])

        var request = try await authenticatedRequest(url: endpoint)
        request.httpMethod = "DELETE"

        _ = try await perform(request, successCodes: 200...204)
    }

    private func restEndpoint(queryItems: [URLQueryItem]) -> URL {
        var components = URLComponents(
            url: supabaseURL.appendingPathComponent("rest/v1/hosts"),
            resolvingAgainstBaseURL: false
        )!
        components.queryItems = queryItems
        return components.url!
    }

    private func authenticatedRequest(
        url: URL,
        context explicitContext: SupabaseSessionContext? = nil
    ) async throws -> URLRequest {
        let context: SupabaseSessionContext
        if let explicitContext {
            context = explicitContext
        } else {
            context = try await requireSession()
        }
        var request = URLRequest(url: url)
        request.setValue(supabaseKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(context.accessToken)", forHTTPHeaderField: "Authorization")
        return request
    }

    private func requireSession() async throws -> SupabaseSessionContext {
        guard let context = try await sessionProvider.currentSessionContext() else {
            throw DomainError.unauthorized
        }
        return context
    }

    private func perform(_ request: URLRequest, successCodes: ClosedRange<Int>) async throws -> Data {
        let (data, response) = try await urlSession.data(for: request)
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
        AppLogger.logNetwork(
            method: request.httpMethod ?? "GET",
            url: request.url?.absoluteString ?? "",
            statusCode: statusCode
        )

        guard successCodes.contains(statusCode) else {
            AppLogger.logNetwork(
                method: request.httpMethod ?? "GET",
                url: request.url?.absoluteString ?? "",
                statusCode: statusCode,
                error: DomainError.unauthorized
            )
            throw DomainError.unauthorized
        }
        return data
    }
}

private struct SupabaseHostDTO: Codable, Sendable {
    let id: UUID
    let userID: UUID
    let name: String
    let hostname: String
    let port: Int
    let username: String
    let privateAddress: String?
    let tags: [String]
    let authMethod: String
    let sshKeyID: UUID?
    let openClawHost: String?
    let openClawPort: Int?
    let openClawScheme: String?
    let openClawBasePath: String?
    let favoriteRemotePath: String?
    let isFavorite: Bool
    let lastSuccessfulConnection: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case name
        case hostname
        case port
        case username
        case privateAddress = "private_address"
        case tags
        case authMethod = "auth_method"
        case sshKeyID = "ssh_key_id"
        case openClawHost = "openclaw_host"
        case openClawPort = "openclaw_port"
        case openClawScheme = "openclaw_scheme"
        case openClawBasePath = "openclaw_base_path"
        case favoriteRemotePath = "favorite_remote_path"
        case isFavorite = "is_favorite"
        case lastSuccessfulConnection = "last_successful_connection"
    }

    init(host: Domain.Host, userID: UUID) {
        id = host.id
        self.userID = userID
        name = host.name
        hostname = host.hostname
        port = host.port
        username = host.username
        privateAddress = host.privateAddress
        tags = host.tags

        switch host.authenticationMethod {
        case .password:
            authMethod = "password"
            sshKeyID = nil
        case .publicKey(let keyID):
            authMethod = "publicKey"
            sshKeyID = keyID
        }

        openClawHost = host.openClawConfiguration?.host
        openClawPort = host.openClawConfiguration?.port
        openClawScheme = host.openClawConfiguration?.scheme
        openClawBasePath = host.openClawConfiguration?.basePath
        favoriteRemotePath = Self.encodeFavoriteRemotePaths(host.favoriteRemotePaths)
        isFavorite = host.isFavorite
        lastSuccessfulConnection = host.lastSuccessfulConnection
    }

    var asDomain: Domain.Host {
        let authenticationMethod: Domain.SSHAuthMethod
        if authMethod == "publicKey", let sshKeyID {
            authenticationMethod = .publicKey(keyID: sshKeyID)
        } else {
            authenticationMethod = .password
        }

        let openClawConfiguration: Domain.OpenClawConfiguration?
        if let openClawHost {
            openClawConfiguration = Domain.OpenClawConfiguration(
                host: openClawHost,
                port: openClawPort ?? 18789,
                scheme: openClawScheme ?? "http",
                basePath: openClawBasePath ?? "/"
            )
        } else {
            openClawConfiguration = nil
        }

        return Domain.Host(
            id: id,
            name: name,
            hostname: hostname,
            port: port,
            username: username,
            privateAddress: privateAddress,
            tags: tags,
            authenticationMethod: authenticationMethod,
            openClawConfiguration: openClawConfiguration,
            favoriteRemotePath: favoriteRemotePath,
            favoriteRemotePaths: Self.decodeFavoriteRemotePaths(favoriteRemotePath),
            lastSuccessfulConnection: lastSuccessfulConnection,
            isFavorite: isFavorite
        )
    }

    private static func encodeFavoriteRemotePaths(_ paths: [String]) -> String? {
        guard !paths.isEmpty else { return nil }
        guard paths.count > 1 else { return paths[0] }
        guard let data = try? JSONEncoder().encode(paths) else { return paths[0] }
        return String(data: data, encoding: .utf8)
    }

    private static func decodeFavoriteRemotePaths(_ value: String?) -> [String] {
        guard let value = value?.trimmingCharacters(in: .whitespacesAndNewlines),
              !value.isEmpty else {
            return []
        }
        if value.hasPrefix("["),
           let data = value.data(using: .utf8),
           let paths = try? JSONDecoder().decode([String].self, from: data) {
            return paths
        }
        return [value]
    }
}
