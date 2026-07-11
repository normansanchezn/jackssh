import Foundation

/// Navigation-only intents decoded from a `jackssh://` URL.
///
/// Deep links are strictly navigational: they may open a screen but must never
/// carry or trigger a destructive action. Any action a link lands on still
/// requires explicit in-app confirmation.
public enum DeepLink: Equatable, Sendable {
    case openClawSession(id: String)
    case serviceLogs(serviceID: String)
    case host(id: String)
    case terminal(hostID: String)
    case files(hostID: String, path: String)
}

public enum DeepLinkParser {
    public static let scheme = "jackssh"

    /// Parses a `jackssh://` URL into a `DeepLink`, or `nil` if unrecognised.
    /// Unknown or malformed links are rejected rather than guessed.
    public static func parse(_ url: URL) -> DeepLink? {
        guard url.scheme == scheme, let host = url.host(percentEncoded: false) else { return nil }
        // Path components excluding the leading "/".
        let parts = url.pathComponents.filter { $0 != "/" }

        switch host {
        case "openclaw":
            // openclaw/session/{id}
            guard parts.count == 2, parts[0] == "session" else { return nil }
            return .openClawSession(id: parts[1])

        case "services":
            // services/{id}/logs
            guard parts.count == 2, parts[1] == "logs" else { return nil }
            return .serviceLogs(serviceID: parts[0])

        case "hosts":
            // hosts/{id}
            guard parts.count == 1 else { return nil }
            return .host(id: parts[0])

        case "terminal":
            // terminal/{hostId}
            guard parts.count == 1 else { return nil }
            return .terminal(hostID: parts[0])

        case "files":
            // files/{hostId}/{path...}
            guard parts.count >= 2 else { return nil }
            let hostID = parts[0]
            let path = "/" + parts.dropFirst().joined(separator: "/")
            return .files(hostID: hostID, path: path)

        default:
            return nil
        }
    }

    public static func parse(_ string: String) -> DeepLink? {
        guard let url = URL(string: string) else { return nil }
        return parse(url)
    }
}
