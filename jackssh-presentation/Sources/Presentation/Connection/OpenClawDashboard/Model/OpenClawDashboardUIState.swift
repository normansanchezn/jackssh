import Foundation
import Domain

public enum OpenClawDashboardStatus: Equatable {
    case idle
    case connectingTunnel
    case ready
    case failed(String)
}

public struct OpenClawDashboardUIState {
    public var host: Domain.Host?
    public var status: OpenClawDashboardStatus = .idle
    public var dashboardURL: URL?
    public var tunnelDescription: String?

    public init() {}
}
