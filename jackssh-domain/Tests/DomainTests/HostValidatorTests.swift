import Testing
@testable import Domain

@Suite("Host validation")
struct HostValidatorTests {
    @Test func acceptsValidDraft() {
        let draft = HostDraft(name: "VPS", hostname: "vps.example", port: 22, username: "root")
        #expect(HostValidator.validate(draft).isEmpty)
    }

    @Test func rejectsEmptyRequiredFields() {
        let draft = HostDraft(name: " ", hostname: "", port: 22, username: "")
        let issues = HostValidator.validate(draft)
        let fields = Set(issues.map(\.field))
        #expect(fields == [.name, .hostname, .username])
    }

    @Test(arguments: [0, -1, 70000])
    func rejectsPortOutOfRange(_ port: Int) {
        let draft = HostDraft(name: "n", hostname: "h", port: port, username: "u")
        #expect(HostValidator.validate(draft).contains { $0.field == .port })
    }

    @Test func rejectsHostnameWithSpaces() {
        let draft = HostDraft(name: "n", hostname: "bad host", port: 22, username: "u")
        #expect(HostValidator.validate(draft).contains { $0.field == .hostname })
    }
}
