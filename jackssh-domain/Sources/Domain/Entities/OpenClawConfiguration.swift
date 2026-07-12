import Foundation

/// Optional OpenClaw dashboard configuration.
public struct OpenClawConfiguration: Equatable, Sendable {
    public let dashboardURL: URL
    public let basePath: String?

    public init(dashboardURL: URL, basePath: String? = nil) {
        self.dashboardURL = dashboardURL
        self.basePath = basePath
    }
}
