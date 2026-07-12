import Foundation

/// Opens an interactive terminal channel through the configured transport.
public struct OpenTerminal: Sendable {
    private let connecting: TerminalConnecting

    public init(connecting: TerminalConnecting) {
        self.connecting = connecting
    }

    public func callAsFunction(to host: Host, cols: Int, rows: Int) async throws -> TerminalChannel {
        try await connecting.connect(to: host, cols: cols, rows: rows)
    }
}
