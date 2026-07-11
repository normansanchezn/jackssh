import Testing
import Foundation
@testable import Domain

@Suite("DeepLink parsing")
struct DeepLinkParserTests {
    @Test func parsesOpenClawSession() {
        #expect(DeepLinkParser.parse("jackssh://openclaw/session/abc123") == .openClawSession(id: "abc123"))
    }

    @Test func parsesServiceLogs() {
        #expect(DeepLinkParser.parse("jackssh://services/docker/logs") == .serviceLogs(serviceID: "docker"))
    }

    @Test func parsesHost() {
        #expect(DeepLinkParser.parse("jackssh://hosts/42") == .host(id: "42"))
    }

    @Test func parsesTerminal() {
        #expect(DeepLinkParser.parse("jackssh://terminal/vps1") == .terminal(hostID: "vps1"))
    }

    @Test func parsesFilesWithNestedPath() {
        #expect(
            DeepLinkParser.parse("jackssh://files/vps1/var/log/openclaw")
                == .files(hostID: "vps1", path: "/var/log/openclaw")
        )
    }

    @Test(arguments: [
        "https://openclaw/session/1",   // wrong scheme
        "jackssh://unknown/1",           // unknown host
        "jackssh://openclaw/session",    // missing id
        "jackssh://services/docker",     // missing /logs
        "jackssh://hosts/1/extra",       // too many parts
        "jackssh://files/onlyhost",      // missing path
    ])
    func rejectsMalformed(_ raw: String) {
        #expect(DeepLinkParser.parse(raw) == nil)
    }
}
