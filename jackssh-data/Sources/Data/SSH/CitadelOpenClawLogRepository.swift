import Foundation
@preconcurrency import Citadel
import Domain
import NIO

@available(macOS 15.0, *)
public struct CitadelOpenClawLogRepository: OpenClawLogRepository {
    private let secretStore: SecretStore
    private let connectTimeout: TimeInterval

    public init(secretStore: SecretStore, connectTimeout: TimeInterval = 15) {
        self.secretStore = secretStore
        self.connectTimeout = connectTimeout
    }

    public func recentLogs(for host: Domain.Host, limit: Int) async throws -> [OpenClawLogEntry] {
        guard host.openClawConfiguration != nil else { return [] }

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

        let command = "sh -lc \(Self.shellQuoted(Self.logsCommand(limit: limit)))"
        let output = try await client.executeCommand(command, maxResponseSize: 131_072)
        return OpenClawLogParser.parse(String(buffer: output), now: Date())
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

    private static func logsCommand(limit: Int) -> String {
        let safeLimit = max(1, min(limit, 500))
        return """
        {
          if command -v openclaw >/dev/null 2>&1; then
            openclaw logs --tail \(safeLimit) 2>/dev/null || true
          fi

          if command -v journalctl >/dev/null 2>&1; then
            journalctl -u openclaw -n \(safeLimit) --no-pager -o short-iso 2>/dev/null || true
            journalctl -u ollama -n \(safeLimit) --no-pager -o short-iso 2>/dev/null | sed 's/^/[ollama] /' || true
          fi

          if command -v docker >/dev/null 2>&1; then
            container_ids="$(docker ps --format '{{.ID}} {{.Names}} {{.Image}}' 2>/dev/null | awk 'tolower($0) ~ /(openclaw|ollama)/ { print $1 }')"
            if [ -z "$container_ids" ]; then
              container_ids="$(docker ps --format '{{.ID}}' 2>/dev/null | awk 'NR <= 20 { print }')"
            fi
            for container_id in $container_ids; do
              container_name="$(docker inspect --format '{{.Name}}' "$container_id" 2>/dev/null | sed 's#^/##')"
              docker logs --tail \(safeLimit) --timestamps "$container_id" 2>&1 | sed "s/^/[$container_name] /" || true
            done
          fi
        } | awk '{
          line=tolower($0)
          if (line ~ /(error|fatal|panic|warn|warning)/) { print; next }
          if (line ~ /ollama/ && line ~ /(^|[^0-9])200([^0-9]|$|")/) { print; next }
          if (line ~ /ollama/ && line ~ /(status|status_code|code)[=: ]+200/) { print; next }
        }' | tail -n \(safeLimit)
        """
    }

    private static func shellQuoted(_ value: String) -> String {
        "'\(value.replacingOccurrences(of: "'", with: "'\\''"))'"
    }
}

enum OpenClawLogParser {
    static func parse(_ output: String, now: Date) -> [OpenClawLogEntry] {
        output
            .components(separatedBy: .newlines)
            .compactMap { parseLine($0, now: now) }
    }

    private static func parseLine(_ line: String, now: Date) -> OpenClawLogEntry? {
        let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let lowercased = trimmed.lowercased()
        let severity: OpenClawLogSeverity
        if lowercased.contains("error") || lowercased.contains("fatal") || lowercased.contains("panic") {
            severity = .error
        } else if lowercased.contains("warning") || lowercased.contains("warn") {
            severity = .warning
        } else if isOllamaSuccess(lowercased) {
            severity = .success
        } else {
            return nil
        }

        let source = sourcePrefix(from: trimmed)
        let message = removeSourcePrefix(from: trimmed)
        return OpenClawLogEntry(
            severity: severity,
            message: message,
            source: source,
            timestamp: timestamp(from: message) ?? now
        )
    }

    private static func sourcePrefix(from line: String) -> String? {
        guard line.hasPrefix("["),
              let endIndex = line.firstIndex(of: "]") else {
            return nil
        }
        let source = line[line.index(after: line.startIndex)..<endIndex]
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return source.isEmpty ? nil : source
    }

    private static func removeSourcePrefix(from line: String) -> String {
        guard line.hasPrefix("["),
              let endIndex = line.firstIndex(of: "]") else {
            return line
        }
        return line[line.index(after: endIndex)...]
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func isOllamaSuccess(_ line: String) -> Bool {
        guard line.contains("ollama") else { return false }
        if line.contains("status=200") || line.contains("status:200") || line.contains("status 200") {
            return true
        }
        if line.contains("status_code=200") || line.contains("status_code:200") || line.contains("code=200") {
            return true
        }
        return line.range(of: #"(^|[^0-9])200([^0-9]|$)"#, options: .regularExpression) != nil
    }

    private static func timestamp(from line: String) -> Date? {
        let firstToken = line.split(separator: " ", maxSplits: 1).first.map(String.init)
        guard let firstToken else { return nil }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: firstToken) ?? ISO8601DateFormatter().date(from: firstToken)
    }
}
