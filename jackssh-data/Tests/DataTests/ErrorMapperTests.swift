import Testing
import Foundation
import Domain
@testable import Data

@Suite("Error mapping")
struct ErrorMapperTests {
    @Test func mapsOfflineURLError() {
        #expect(ErrorMapper.map(URLError(.notConnectedToInternet)) == .offline)
    }

    @Test func mapsUnreachableURLError() {
        #expect(ErrorMapper.map(URLError(.cannotConnectToHost)) == .unreachable)
    }

    @Test func mapsTimeout() {
        #expect(ErrorMapper.map(URLError(.timedOut)) == .timeout)
    }

    @Test func passesThroughDomainError() {
        #expect(ErrorMapper.map(DomainError.hostKeyChanged) == .hostKeyChanged)
    }

    @Test func mapsKeychainNotFound() {
        #expect(ErrorMapper.map(KeychainError(status: errSecItemNotFound)) == .notFound)
    }

    @Test func mapsUnknownError() {
        struct Weird: Error {}
        #expect(ErrorMapper.map(Weird()) == .unknown)
    }
}
