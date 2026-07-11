import Foundation
import Domain

/// Real HTTP health probe over `URLSession`. Performs a GET and maps the outcome
/// to a `HealthState`. No sensitive data is logged.
public struct URLSessionHealthProbe: HTTPHealthProbe {
    private let session: URLSession
    private let timeout: TimeInterval

    public init(session: URLSession = .shared, timeout: TimeInterval = 5) {
        self.session = session
        self.timeout = timeout
    }

    public func probe(_ url: URL) async -> HealthState {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = timeout

        do {
            let (_, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse else { return .unknown }
            switch http.statusCode {
            case 200..<400: return .online
            case 500...:    return .offline
            default:        return .degraded   // 4xx: reachable but unhealthy
            }
        } catch {
            // Network-level failures mean the service is unreachable.
            switch ErrorMapper.map(error) {
            case .offline, .unreachable, .timeout: return .offline
            default: return .unknown
            }
        }
    }
}
