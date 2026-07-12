import Foundation
import Observation
import Domain

/// Owns the navigation stack. `@Observable` so SwiftUI binds to `path` directly.
/// Deep-link handling is centralised here and is strictly navigational.
@MainActor
@Observable
public final class AppRouter {
    public var path: [AppRoute]

    public init(path: [AppRoute] = []) {
        self.path = path
    }

    public func push(_ route: AppRoute) {
        path.append(route)
    }

    /// Replaces the current transient destination without adding a second back
    /// step. Used when an in-progress screen resolves into its final screen.
    public func replaceTop(with route: AppRoute) {
        guard !path.isEmpty else {
            path.append(route)
            return
        }
        path[path.index(before: path.endIndex)] = route
    }

    public func popToRoot() {
        path.removeAll()
    }

    public func handle(_ deepLink: DeepLink) {
        path.append(AppRoute(deepLink: deepLink))
    }

    /// Handles an incoming URL. Returns `false` for unrecognised URLs so the
    /// caller can ignore them. Never triggers a destructive action.
    @discardableResult
    public func handle(url: URL) -> Bool {
        guard let deepLink = DeepLinkParser.parse(url) else { return false }
        handle(deepLink)
        return true
    }
}
