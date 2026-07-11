import Testing
@testable import Domain

@Suite("Service state resolution")
struct ServiceStateResolverTests {
    @Test func offlineWhenUnreachable() {
        #expect(ServiceStateResolver.resolve(.init(reachable: false, running: true, healthyRatio: 1)) == .offline)
    }

    @Test func offlineWhenNotRunning() {
        #expect(ServiceStateResolver.resolve(.init(reachable: true, running: false, healthyRatio: 1)) == .offline)
    }

    @Test func unknownWhenNoHealthData() {
        #expect(ServiceStateResolver.resolve(.init(reachable: true, running: true, healthyRatio: nil)) == .unknown)
    }

    @Test func onlineWhenFullyHealthy() {
        #expect(ServiceStateResolver.resolve(.init(reachable: true, running: true, healthyRatio: 1)) == .online)
    }

    @Test func degradedWhenPartiallyHealthy() {
        #expect(ServiceStateResolver.resolve(.init(reachable: true, running: true, healthyRatio: 0.5)) == .degraded)
    }
}
