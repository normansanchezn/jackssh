import Foundation
import Domain

/// Typed navigation destinations for the app's `NavigationStack`.
/// String identifiers keep this layer aligned with incoming deep links.
public enum AppRoute: Hashable, Sendable {
    case hosts
    case host(id: String)
    case openClawSession(id: String)
    case serviceLogs(serviceID: String)
    case terminal(hostID: String)
    case files(hostID: String, path: String)
}

public extension AppRoute {
    /// Maps a navigational `DeepLink` intent onto a route.
    ///
    /// Deep links are navigation only — this never performs an action, it only
    /// selects a screen. Any destructive operation on the destination still
    /// requires explicit confirmation there.
    init(deepLink: DeepLink) {
        switch deepLink {
        case let .openClawSession(id): self = .openClawSession(id: id)
        case let .serviceLogs(serviceID): self = .serviceLogs(serviceID: serviceID)
        case let .host(id): self = .host(id: id)
        case let .terminal(hostID): self = .terminal(hostID: hostID)
        case let .files(hostID, path): self = .files(hostID: hostID, path: path)
        }
    }
}
