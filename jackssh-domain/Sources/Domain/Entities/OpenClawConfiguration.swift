import Foundation

/// Optional OpenClaw dashboard configuration.
public struct OpenClawConfiguration: Equatable, Sendable {
    public let host: String
    public let port: Int
    public let scheme: String // "http" or "https"
    public let basePath: String

    public init(host: String, port: Int = 18789, scheme: String = "http", basePath: String = "/") {
        self.host = host
        self.port = port
        self.scheme = scheme
        self.basePath = basePath
    }

    public var dashboardURL: URL? {
        URL(string: "\(scheme)://\(host):\(port)\(basePath)")
    }
}
