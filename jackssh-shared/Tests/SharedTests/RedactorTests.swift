import Testing
@testable import Shared

@Suite("Redactor")
struct RedactorTests {
    @Test func masksRegisteredSecret() {
        let redactor = Redactor(secrets: ["hunter2"])
        #expect(redactor.redact("password is hunter2 ok") == "password is \(Redactor.mask) ok")
    }

    @Test func masksMultipleAndOverlapping() {
        let redactor = Redactor(secrets: ["token", "tokenABC"])
        // Longest-first ensures the full token is masked, not a prefix.
        #expect(redactor.redact("tokenABC").contains(Redactor.mask))
        #expect(!redactor.redact("tokenABC").contains("ABC"))
    }

    @Test func leavesCleanTextUntouched() {
        let redactor = Redactor(secrets: ["secret"])
        #expect(redactor.redact("nothing here") == "nothing here")
    }

    @Test func emptySecretsAreIgnored() {
        // Empty strings must not turn every position into a mask.
        let redactor = Redactor(secrets: ["", "abc"])
        #expect(redactor.redact("no match") == "no match")
    }
}
