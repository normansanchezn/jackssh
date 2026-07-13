import Foundation

public enum OpenClawLogSeverity: String, Equatable, Sendable {
    case error
    case warning
    case success
}

public struct OpenClawLogEntry: Identifiable, Equatable, Sendable {
    public let id: UUID
    public let severity: OpenClawLogSeverity
    public let message: String
    public let source: String?
    public let timestamp: Date

    public init(
        id: UUID = UUID(),
        severity: OpenClawLogSeverity,
        message: String,
        source: String? = nil,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.severity = severity
        self.message = message
        self.source = source
        self.timestamp = timestamp
    }
}
