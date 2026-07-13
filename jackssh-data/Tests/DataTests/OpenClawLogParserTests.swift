import Foundation
import Testing
@testable import Data
import Domain

@Suite("OpenClaw log parsing")
struct OpenClawLogParserTests {
    @Test func keepsOnlyWarningAndErrorLogs() {
        let now = Date(timeIntervalSince1970: 100)
        let output = """
        [openclaw] 2026-07-12T21:12:00Z INFO dashboard ready
        [openclaw] 2026-07-12T21:13:00Z WARN token refresh is slow
        [openclaw-api] 2026-07-12T21:14:00Z ERROR failed to reach worker
        debug cache hit
        """

        let logs = OpenClawLogParser.parse(output, now: now)

        #expect(logs.map(\.severity) == [.warning, .error])
        #expect(logs.first?.source == "openclaw")
        #expect(logs.last?.source == "openclaw-api")
        #expect(logs.first?.message.contains("token refresh is slow") == true)
    }

    @Test func includesOllamaSuccessAndErrorEvents() {
        let now = Date(timeIntervalSince1970: 100)
        let output = """
        [ollama] 2026-07-12T21:15:00Z POST /api/generate 200 184ms
        [ollama] 2026-07-12T21:16:00Z ERROR model llama3 not found
        [ollama] 2026-07-12T21:17:00Z GET /api/tags 404
        """

        let logs = OpenClawLogParser.parse(output, now: now)

        #expect(logs.map(\.severity) == [.success, .error])
        #expect(logs.map(\.source) == ["ollama", "ollama"])
        #expect(logs.first?.message.contains("200") == true)
        #expect(logs.last?.message.contains("model llama3 not found") == true)
    }
}
