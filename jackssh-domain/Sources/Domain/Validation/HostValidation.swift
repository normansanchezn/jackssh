import Foundation

/// A single field-level validation failure.
public struct ValidationIssue: Equatable, Sendable {
    public enum Field: String, Sendable {
        case name, hostname, port, username
        case authenticationMethod
        case openClawHost, openClawPort, openClawScheme, openClawBasePath
        case favoriteRemotePath
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
    public var authenticationMethod: SSHAuthMethod
    public var openClawHost: String?
    public var openClawPort: Int?
    public var openClawScheme: String?
    public var openClawBasePath: String?
    public var favoriteRemotePath: String?

    public init(
        name: String,
        hostname: String,
        port: Int,
        username: String,
        authenticationMethod: SSHAuthMethod = .password,
        openClawHost: String? = nil,
        openClawPort: Int? = nil,
        openClawScheme: String? = nil,
        openClawBasePath: String? = nil,
        favoriteRemotePath: String? = nil
    ) {
        self.name = name
        self.hostname = hostname
        self.port = port
        self.username = username
        self.authenticationMethod = authenticationMethod
        self.openClawHost = openClawHost
        self.openClawPort = openClawPort
        self.openClawScheme = openClawScheme
        self.openClawBasePath = openClawBasePath
        self.favoriteRemotePath = favoriteRemotePath
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

        if let openClawHost = draft.openClawHost, !openClawHost.isEmpty {
            if let port = draft.openClawPort, !(1...65535).contains(port) {
                issues.append(.init(field: .openClawPort, message: "OpenClaw port must be between 1 and 65535."))
            }
            if let scheme = draft.openClawScheme, !["http", "https"].contains(scheme) {
                issues.append(.init(field: .openClawScheme, message: "Scheme must be http or https."))
            }
        }

        return issues
    }
}
