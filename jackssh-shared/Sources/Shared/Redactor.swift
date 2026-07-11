import Foundation

/// Masks sensitive values before anything reaches a log sink.
///
/// The security rule is "never log passwords, private keys, tokens, or sensitive
/// command output." This is the single choke point used by the app's logging so
/// registered secrets can never appear in plaintext logs.
public struct Redactor: Sendable {
    public static let mask = "•••redacted•••"

    private let secrets: [String]

    public init(secrets: [String] = []) {
        // Ignore empties; longest-first so overlapping secrets mask fully.
        self.secrets = secrets
            .filter { !$0.isEmpty }
            .sorted { $0.count > $1.count }
    }

    /// Returns `text` with every registered secret replaced by the mask.
    public func redact(_ text: String) -> String {
        var output = text
        for secret in secrets {
            output = output.replacingOccurrences(of: secret, with: Self.mask)
        }
        return output
    }
}
