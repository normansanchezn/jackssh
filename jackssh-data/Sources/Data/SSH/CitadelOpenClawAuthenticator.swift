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
        return OpenClawTokenExtractor.extract(from: String(buffer: output))
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

    private static func shellQuoted(_ value: String) -> String {
        "'\(value.replacingOccurrences(of: "'", with: "'\\''"))'"
    }
}

enum OpenClawTokenExtractor {
    private static let jsonKeys = [
        "token",
        "openclaw_token",
        "access_token",
        "authToken",
        "jwt",
    ]

    private static let keyValueNames = [
        "OPENCLAW_TOKEN",
        "OPENCLAW_AUTH_TOKEN",
        "OPENCLAW_DASHBOARD_TOKEN",
        "DASHBOARD_TOKEN",
        "AUTH_TOKEN",
        "AUTHORIZATION",
        "ACCESS_TOKEN",
        "JWT",
        "TOKEN",
        "openclaw_token",
        "access_token",
        "authToken",
        "jwt",
        "token",
    ]

    static func extract(from output: String) -> String? {
        let trimmed = output.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        if let token = tokenFromJSON(trimmed) {
            return token
        }

        let lines = trimmed
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        for line in lines {
            if let token = tokenFromJSON(line) {
                return token
            }
            if let token = tokenFromBearerHeader(line) {
                return token
            }
            if let token = tokenFromKeyValue(line) {
                return token
            }
            if let token = tokenFromJWT(in: line) {
                return token
            }
        }

        return lines.first(where: isPlainToken)
    }

    private static func tokenFromJSON(_ value: String) -> String? {
        guard let data = value.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }

        for key in jsonKeys {
            if let token = json[key] as? String, isUsableToken(token) {
                return normalized(token)
            }
        }

        if let auth = json["authorization"] as? String,
           let token = tokenFromBearerHeader(auth) {
            return token
        }

        return nil
    }

    private static func tokenFromBearerHeader(_ line: String) -> String? {
        let marker = "Bearer "
        guard let range = line.range(of: marker, options: [.caseInsensitive]) else { return nil }
        let token = String(line[range.upperBound...])
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "'\""))
        return isUsableToken(token) ? token : nil
    }

    private static func tokenFromKeyValue(_ line: String) -> String? {
        for name in keyValueNames {
            if let token = value(after: "\(name)=", in: line) ?? value(after: "\(name):", in: line) {
                return token
            }
        }
        return nil
    }

    private static func value(after marker: String, in line: String) -> String? {
        guard let range = line.range(of: marker, options: [.caseInsensitive]) else { return nil }
        let token = String(line[range.upperBound...])
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "'\""))
        return isUsableToken(token) ? normalized(token) : nil
    }

    private static func tokenFromJWT(in line: String) -> String? {
        let pattern = #"eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)),
              let range = Range(match.range, in: line) else {
            return nil
        }
        return String(line[range])
    }

    private static func isPlainToken(_ line: String) -> Bool {
        let token = normalized(line)
        guard isUsableToken(token) else { return false }
        guard token.count >= 16 else { return false }
        guard token.rangeOfCharacter(from: .whitespacesAndNewlines) == nil else { return false }
        guard !token.contains("/") || token.contains(".") else { return false }

        let lowercased = token.lowercased()
        let rejectedPrefixes = ["warning", "error", "docker", "unable", "cannot", "failed", "usage"]
        return !rejectedPrefixes.contains { lowercased.hasPrefix($0) }
    }

    private static func isUsableToken(_ value: String) -> Bool {
        !normalized(value).isEmpty
    }

    private static func normalized(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "'\""))
    }
}
