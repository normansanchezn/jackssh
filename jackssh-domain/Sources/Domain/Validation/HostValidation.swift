import Foundation

/// A single field-level validation failure.
public struct ValidationIssue: Equatable, Sendable {
    public enum Field: String, Sendable {
        case name, hostname, port, username
    }
    public let field: Field
    public let message: String

    public init(field: Field, message: String) {
        self.field = field
        self.message = message
    }
}

/// Draft input used when creating or editing a host, before it becomes a valid `Host`.
public struct HostDraft: Equatable, Sendable {
    public var name: String
    public var hostname: String
    public var port: Int
    public var username: String

    public init(name: String, hostname: String, port: Int, username: String) {
        self.name = name
        self.hostname = hostname
        self.port = port
        self.username = username
    }
}

/// Pure host validation. No I/O — trivially testable.
public enum HostValidator {
    public static func validate(_ draft: HostDraft) -> [ValidationIssue] {
        var issues: [ValidationIssue] = []
        let name = draft.name.trimmingCharacters(in: .whitespacesAndNewlines)
        let hostname = draft.hostname.trimmingCharacters(in: .whitespacesAndNewlines)
        let username = draft.username.trimmingCharacters(in: .whitespacesAndNewlines)

        if name.isEmpty {
            issues.append(.init(field: .name, message: "Name is required."))
        }
        if hostname.isEmpty {
            issues.append(.init(field: .hostname, message: "Hostname is required."))
        } else if hostname.contains(" ") {
            issues.append(.init(field: .hostname, message: "Hostname must not contain spaces."))
        }
        if !(1...65535).contains(draft.port) {
            issues.append(.init(field: .port, message: "Port must be between 1 and 65535."))
        }
        if username.isEmpty {
            issues.append(.init(field: .username, message: "Username is required."))
        }
        return issues
    }
}
