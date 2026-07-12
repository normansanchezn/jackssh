import Foundation
import Observation
import Domain

/// Backs the create/edit host form. Owns editable field state and surfaces
/// per-field validation issues produced by `SaveHost` / `HostValidator`.
@MainActor
@Observable
public final class HostEditorViewModel {
    public private(set) var uiState: HostEditorUIState
    public private(set) var effect: HostEditorEffect = .none

    public var name: String {
        get { uiState.name }
        set { uiState.name = newValue }
    }
    public var hostname: String {
        get { uiState.hostname }
        set { uiState.hostname = newValue }
    }
    public var port: String {
        get { uiState.port }
        set { uiState.port = newValue }
    }
    public var username: String {
        get { uiState.username }
        set { uiState.username = newValue }
    }
    public var showPasswordField: Bool { uiState.showPasswordField }
    public var password: String {
        get { uiState.password }
        set { uiState.password = newValue }
    }
    public var passwordConfirmation: String {
        get { uiState.passwordConfirmation }
        set { uiState.passwordConfirmation = newValue }
    }
    public var authenticationMethod: SSHAuthMethod { uiState.authenticationMethod }
    public var openClawHost: String {
        get { uiState.openClawHost }
        set { uiState.openClawHost = newValue }
    }
    public var openClawPort: String {
        get { uiState.openClawPort }
        set { uiState.openClawPort = newValue }
    }
    public var openClawScheme: String {
        get { uiState.openClawScheme }
        set { uiState.openClawScheme = newValue }
    }
    public var openClawBasePath: String {
        get { uiState.openClawBasePath }
        set { uiState.openClawBasePath = newValue }
    }
    public var favoriteRemotePath: String {
        get { uiState.favoriteRemotePath }
        set { uiState.favoriteRemotePath = newValue }
    }
    public var issues: [ValidationIssue] { uiState.issues }
    public var isSaving: Bool { uiState.isSaving }

    private let saveHost: SaveHost
    private let editingID: UUID?

    public var isEditing: Bool { editingID != nil }
    public var title: String { isEditing ? "Edit Host" : "New Host" }

    /// New host.
    public init(saveHost: SaveHost) {
        self.saveHost = saveHost
        self.editingID = nil
        self.uiState = HostEditorUIState()
    }

    /// Edit existing host.
    public init(saveHost: SaveHost, host: Domain.Host) {
        self.saveHost = saveHost
        self.editingID = host.id
        self.uiState = HostEditorUIState(host: host)
    }

    public func issue(for field: ValidationIssue.Field) -> String? {
        uiState.issues.first { $0.field == field }?.message
    }

    public func setAuthMethod(_ method: SSHAuthMethod) {
        uiState.authenticationMethod = method
        switch method {
        case .password:
            uiState.showPasswordField = true
        case .publicKey:
            uiState.showPasswordField = false
        }
    }

    /// Attempts to save. Returns the saved host on success, or `nil` when the
    /// draft is invalid (issues populated) or a save error occurs.
    @discardableResult
    public func save() async -> Domain.Host? {
        uiState.issues = []
        uiState.isSaving = true
        defer { uiState.isSaving = false }

        let openClawPort: Int? = openClawHost.isEmpty ? nil : (Int(openClawPort) ?? nil)

        let draft = HostDraft(
            name: name,
            hostname: hostname,
            port: Int(port) ?? -1,
            username: username,
            authenticationMethod: authenticationMethod,
            openClawHost: openClawHost.isEmpty ? nil : openClawHost,
            openClawPort: openClawPort,
            openClawScheme: openClawHost.isEmpty ? nil : openClawScheme,
            openClawBasePath: openClawHost.isEmpty ? nil : openClawBasePath,
            favoriteRemotePath: favoriteRemotePath.isEmpty ? nil : favoriteRemotePath
        )

        let draftIssues = HostValidator.validate(draft)
        guard draftIssues.isEmpty else {
            uiState.issues = draftIssues
            effect = .showError("Please fix the highlighted fields.")
            return nil
        }

        // Prepare credential data
        var credentialData: Data? = nil
        if case .password = authenticationMethod {
            if !isEditing && password.isEmpty {
                uiState.issues = [
                    ValidationIssue(field: .authenticationMethod, message: "Password is required for new password-based hosts.")
                ]
                effect = .showError("Password is required.")
                return nil
            }
            if !password.isEmpty {
                guard password == passwordConfirmation else {
                    uiState.issues = [
                        ValidationIssue(field: .authenticationMethod, message: "Passwords do not match.")
                    ]
                    effect = .showError("Passwords do not match.")
                    return nil
                }
                credentialData = password.data(using: .utf8)
            }
        }

        do {
            let host = try await saveHost(
                draft,
                id: editingID ?? UUID(),
                credential: credentialData
            )
            effect = .saved(host)
            return host
        } catch let DomainError.validation(validationIssues) {
            uiState.issues = validationIssues
            effect = .showError("Please fix the highlighted fields.")
            return nil
        } catch {
            uiState.issues = [ValidationIssue(field: .name, message: "Couldn’t save. Try again.")]
            effect = .showError("Couldn’t save. Try again.")
            return nil
        }
    }

    public func clearEffect() {
        effect = .none
    }
}
