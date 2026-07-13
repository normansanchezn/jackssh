import Testing
@testable import Data

@Suite("OpenClaw token extraction")
struct OpenClawTokenExtractorTests {
    @Test func extractsTokenFromJSON() {
        let output = #"{"access_token":"dashboard-token-123456"}"#

        #expect(OpenClawTokenExtractor.extract(from: output) == "dashboard-token-123456")
    }

    @Test func extractsTokenFromOpenClawSecretsJSON() {
        let output = """
        {
          "gateway": {
            "auth": {
              "token": "openclaw-gateway-token-abcdef"
            }
          }
        }
        """

        #expect(OpenClawTokenExtractor.extract(from: output) == "openclaw-gateway-token-abcdef")
    }

    @Test func extractsTokenFromNestedDashboardJSON() {
        let output = """
        {
          "dashboard": {
            "auth": {
              "token": "openclaw-dashboard-token-nested"
            }
          }
        }
        """

        #expect(OpenClawTokenExtractor.extract(from: output) == "openclaw-dashboard-token-nested")
    }

    @Test func skipsWarningsAndExtractsBearerToken() {
        let output = """
        Warning: container has no TTY
        Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJvcGVuY2xhdyJ9.signature
        """

        #expect(
            OpenClawTokenExtractor.extract(from: output)
                == "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJvcGVuY2xhdyJ9.signature"
        )
    }

    @Test func extractsTokenFromEnvironmentOutput() {
        let output = """
        PATH=/usr/local/bin
        OPENCLAW_DASHBOARD_TOKEN='openclaw-dashboard-token-abcdef'
        """

        #expect(OpenClawTokenExtractor.extract(from: output) == "openclaw-dashboard-token-abcdef")
    }

    @Test func returnsPlainTokenWhenCommandPrintsOnlyToken() {
        #expect(OpenClawTokenExtractor.extract(from: "plain-openclaw-token-abcdef") == "plain-openclaw-token-abcdef")
    }
}
