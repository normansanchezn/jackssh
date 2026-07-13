#if os(iOS) && canImport(ActivityKit)
import ActivityKit
import Foundation

public struct PortForwardActivityAttributes: ActivityAttributes, Sendable {
    public struct ContentState: Codable, Hashable, Sendable {
        public let hostName: String
        public let tunnelDescription: String
        public let localPort: Int
        public let startedAt: Date
        public let status: String

        public init(
            hostName: String,
            tunnelDescription: String,
            localPort: Int,
            startedAt: Date,
            status: String
        ) {
            self.hostName = hostName
            self.tunnelDescription = tunnelDescription
            self.localPort = localPort
            self.startedAt = startedAt
            self.status = status
        }
    }

    public let hostID: String
    public let hostName: String

    public init(hostID: String, hostName: String) {
        self.hostID = hostID
        self.hostName = hostName
    }
}
#endif
