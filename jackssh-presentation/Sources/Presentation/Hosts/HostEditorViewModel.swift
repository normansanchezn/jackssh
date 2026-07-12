import Foundation
import Observation
import Domain

/// Backs the create/edit host form. Owns editable field state and surfaces
/// per-field validation issues produced by `SaveHost` / `HostValidator`.
@MainActor
@Observable
public final class HostEditorViewModel {
    public var name: String
    public var hostname: String
    public var port: String
    public var username: String
    public var showPasswordField: Bool = false
    public var password: String = ""
    public var passwordConfirmation: String = ""
    public var authenticationMethod: SSHAuthMethod = .password
    public var openClawDashboardURL: String = ""
    public var openClawBasePath: String = ""
    public var favoriteRemotePath: String = ""

    public private(set) var issues: [ValidationIssue] = []
    public private(set) var isSaving = false

    private let saveHost: SaveHost
    private let editingID: UUID?

    public var isEditing: Bool { editingID != nil }
    public var title: String { isEditing ? "Edit Host" : "New Host" }

    /// New host.
    public init(saveHost: SaveHost) {
        self.saveHost = saveHost
        self.editingID = nil
        self.name = ""
        self.hostname = ""
        self.port = "22"
        self.username = ""
    }

    /// Edit existing host.
    public init(saveHost: SaveHost, host: Domain.Host) {
        self.saveHost = saveHost
        self.editingID = host.id
        self.name = host.name
        self.hostname = host.hostname
        self.port = String(host.port)
        self.username = host.username
    }

    public func issue(for field: ValidationIssue.Field) -> String? {
        issues.first { $0.field == field }?.message
    }

    public func setAuthMethod(_ method: SSHAuthMethod) {
        authenticationMethod = method
        switch method {
        case .password:
            showPasswordField = true
        case .publicKey:
            showPasswordField = false
        }
    }

    /// Attempts to save. Returns the saved host on success, or `nil` when the
    /// draft is invalid (issues populated) or a save error occurs.
    @discardableResult
    public func save() async -> Domain.Host? {
        issues = []
        isSaving = true
        defer { isSaving = false }

        let draft = HostDraft(
            name: name,
            hostname: hostname,
            port: Int(port) ?? -1,
            username: username,
            authenticationMethod: authenticationMethod,
            openClawDashboardURL: openClawDashboardURL.isEmpty ? nil : openClawDashboardURL,
            openClawBasePath: openClawBasePath.isEmpty ? nil : openClawBasePath,
            favoriteRemotePath: favoriteRemotePath.isEmpty ? nil : favoriteRemotePath
        )
        do {
            return try await saveHost(draft, id: editingID ?? UUID())
        } catch let DomainError.validation(validationIssues) {
            issues = validationIssues
            return nil
        } catch {
            issues = [ValidationIssue(field: .name, message: "Couldn’t save. Try again.")]
            return nil
        }
    }
}
