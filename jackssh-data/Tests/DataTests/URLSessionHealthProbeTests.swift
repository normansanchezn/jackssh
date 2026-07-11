import Testing
import Foundation
import Domain
@testable import Data

/// Intercepts URLSession traffic so the HTTP probe can be tested without a network.
private final class StubURLProtocol: URLProtocol {
    nonisolated(unsafe) static var statusCode: Int = 200
    nonisolated(unsafe) static var failWith: Error?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override func stopLoading() {}

    override func startLoading() {
        if let error = Self.failWith {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }
        let response = HTTPURLResponse(
            url: request.url!, statusCode: Self.statusCode, httpVersion: nil, headerFields: nil
        )!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: Data())
        client?.urlProtocolDidFinishLoading(self)
    }
}

@Suite("URLSessionHealthProbe", .serialized)
struct URLSessionHealthProbeTests {
    private func makeProbe() -> URLSessionHealthProbe {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [StubURLProtocol.self]
        return URLSessionHealthProbe(session: URLSession(configuration: config))
    }

    private let url = URL(string: "http://10.0.0.2/health")!

    @Test func mapsSuccessToOnline() async {
        StubURLProtocol.failWith = nil
        StubURLProtocol.statusCode = 200
        #expect(await makeProbe().probe(url) == .online)
    }

    @Test func mapsServerErrorToOffline() async {
        StubURLProtocol.failWith = nil
        StubURLProtocol.statusCode = 503
        #expect(await makeProbe().probe(url) == .offline)
    }

    @Test func mapsClientErrorToDegraded() async {
        StubURLProtocol.failWith = nil
        StubURLProtocol.statusCode = 404
        #expect(await makeProbe().probe(url) == .degraded)
    }

    @Test func mapsNetworkFailureToOffline() async {
        StubURLProtocol.failWith = URLError(.cannotConnectToHost)
        #expect(await makeProbe().probe(url) == .offline)
    }
}
