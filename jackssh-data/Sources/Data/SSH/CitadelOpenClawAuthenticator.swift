import Foundation
@preconcurrency import Citadel
import Domain
import NIO

/// Retrieves an OpenClaw dashboard token by executing the configured command on
/// the VPS over SSH. Tokens are returned to Presentation in memory only.
@available(macOS 15.0, *)
public struct CitadelOpenClawAuthenticator: OpenClawAuthenticating {
    private let secretStore: SecretStore
    private let connectTimeout: TimeInterval

    public init(secretStore: SecretStore, connectTimeout: TimeInterval = 15) {
        self.secretStore = secretStore
        self.connectTimeout = connectTimeout
    }

    public func token(for host: Domain.Host, configuration: OpenClawConfiguration) async throws -> String? {
        let auth = try await authentication(for: host)
        let client = try await SSHClient.connect(
            host: host.hostname,
            port: host.port,
            authenticationMethod: auth,
            hostKeyValidator: .acceptAnything(), // TODO: TOFU host-key store
            reconnect: .never,
            connectTimeout: .seconds(Int64(connectTimeout))
        )
        defer {
            Task { try? await client.close() }
        }

        let command = "sh -lc \(Self.shellQuoted(configuration.resolvedAuthTokenCommand))"
        let output = try await client.executeCommand(command, maxResponseSize: 16_384)
        return Self.extractToken(from: String(buffer: output))
    }

    private func authentication(for host: Domain.Host) async throws -> SSHAuthenticationMethod {
        switch host.authenticationMethod {
        case .password:
            let key = SecretKey.password(hostID: host.id)
            guard let data = try await secretStore.secret(for: key),
                  let password = String(data: data, encoding: .utf8) else {
                throw DomainError.notFound
            }
            return .passwordBased(username: host.username, password: password)

        case .publicKey:
            throw DomainError.unknown
        }
    }

    private static func extractToken(from output: String) -> String? {
        let trimmed = output.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        if let data = trimmed.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            for key in ["token", "access_token", "authToken", "jwt"] {
                if let value = json[key] as? String, !value.isEmpty {
                    return value
                }
            }
        }

        return trimmed
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .first { !$0.isEmpty }
    }

    private static func shellQuoted(_ value: String) -> String {
        "'\(value.replacingOccurrences(of: "'", with: "'\\''"))'"
    }
}
