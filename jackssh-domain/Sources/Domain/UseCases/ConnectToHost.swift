import Foundation

/// Performs one SSH connection attempt using the configured transport.
/// The transport implementation belongs to Data; Presentation observes only
/// the domain result through this use case.
public struct ConnectToHost: Sendable {
    private let connector: SSHConnector

    public init(connector: SSHConnector) {
        self.connector = connector
    }

    public func callAsFunction(to host: Host) async -> SSHConnectionResult {
        await connector.connect(to: host)
    }
}
