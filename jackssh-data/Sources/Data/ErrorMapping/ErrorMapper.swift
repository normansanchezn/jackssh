import Foundation
import Domain

/// Maps infrastructure errors into the stable `DomainError` taxonomy so upper
/// layers never branch on `URLError`, `OSStatus`, or other implementation types.
public enum ErrorMapper {
    public static func map(_ error: Error) -> DomainError {
        if let domain = error as? DomainError { return domain }
        if let keychain = error as? KeychainError { return keychain.asDomainError }
        if let urlError = error as? URLError { return map(urlError) }
        return .unknown
    }

    private static func map(_ error: URLError) -> DomainError {
        switch error.code {
        case .notConnectedToInternet, .dataNotAllowed:
            return .offline
        case .cannotConnectToHost, .cannotFindHost, .networkConnectionLost:
            return .unreachable
        case .timedOut:
            return .timeout
        case .userAuthenticationRequired:
            return .unauthorized
        default:
            return .unknown
        }
    }
}
