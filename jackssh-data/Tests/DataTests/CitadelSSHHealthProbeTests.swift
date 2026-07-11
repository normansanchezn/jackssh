import Testing
import Foundation
import Domain
@testable import Data

@Suite("CitadelSSHHealthProbe")
struct CitadelSSHHealthProbeTests {
    /// Safety contract: when the target isn't fully/securely configured the probe
    /// must report `.unknown` and must NOT attempt a connection.
    @Test func refusesToConnectWhenUnconfigured() async {
        let probe = CitadelSSHHealthProbe(sessionProvider: { _ in nil })
        let target = SSHTarget(host: "10.0.0.2", username: "root")
        #expect(await probe.probe(target) == .unknown)
    }
}
