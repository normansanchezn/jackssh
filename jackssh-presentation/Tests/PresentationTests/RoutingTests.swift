import Testing
import Foundation
import Domain
@testable import Presentation

@Suite("Deep link routing")
struct RoutingTests {
    @Test func mapsEachDeepLinkToRoute() {
        #expect(AppRoute(deepLink: .host(id: "1")) == .host(id: "1"))
        #expect(AppRoute(deepLink: .terminal(hostID: "v")) == .terminal(hostID: "v"))
        #expect(AppRoute(deepLink: .serviceLogs(serviceID: "docker")) == .serviceLogs(serviceID: "docker"))
        #expect(AppRoute(deepLink: .openClawSession(id: "s")) == .openClawSession(id: "s"))
        #expect(AppRoute(deepLink: .files(hostID: "v", path: "/x")) == .files(hostID: "v", path: "/x"))
    }

    @MainActor
    @Test func routerHandlesValidURLAndPushes() {
        let router = AppRouter()
        let handled = router.handle(url: URL(string: "jackssh://hosts/42")!)
        #expect(handled)
        #expect(router.path == [.host(id: "42")])
    }

    @MainActor
    @Test func routerIgnoresUnknownURL() {
        let router = AppRouter()
        let handled = router.handle(url: URL(string: "jackssh://bogus/1")!)
        #expect(!handled)
        #expect(router.path.isEmpty)
    }
}
