import Foundation

/// Optional OpenClaw dashboard configuration.
public struct OpenClawConfiguration: Equatable, Sendable {
    public let host: String
    public let port: Int
    public let scheme: String // "http" or "https"
    public let basePath: String
    public let authTokenCommand: String?

    public init(
        host: String,
        port: Int = 18789,
        scheme: String = "http",
        basePath: String = "/",
        authTokenCommand: String? = nil
    ) {
        self.host = host
        self.port = port
        self.scheme = scheme
        self.basePath = basePath
        self.authTokenCommand = authTokenCommand
    }

    public var dashboardURL: URL? {
        URL(string: "\(scheme)://\(host):\(port)\(basePath)")
    }

    public var resolvedAuthTokenCommand: String {
        authTokenCommand ?? Self.defaultAuthTokenCommand
    }

    private static let defaultAuthTokenCommand = """
    if [ -f "$HOME/.openclaw/token" ]; then cat "$HOME/.openclaw/token"; elif [ -f "/root/.openclaw/token" ]; then cat "/root/.openclaw/token"; elif command -v openclaw >/dev/null 2>&1; then openclaw auth token 2>/dev/null || openclaw token 2>/dev/null || true; else true; fi
    """
}
