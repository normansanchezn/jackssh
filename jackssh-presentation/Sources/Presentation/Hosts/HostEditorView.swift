import SwiftUI
import Domain
import DesignSystem

/// Create/edit host form. Uses a standard `Form` for native field behavior,
/// Dynamic Type, and VoiceOver. Validation messages come from the view model.
public struct HostEditorView: View {
    @State private var viewModel: HostEditorViewModel
    private let onFinished: (_ saved: Bool) -> Void

    public init(viewModel: HostEditorViewModel, onFinished: @escaping (_ saved: Bool) -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onFinished = onFinished
    }

    public var body: some View {
        Form {
            Section("Connection") {
                field("Name", text: $viewModel.name, field: .name, kind: .words)
                field("Hostname", text: $viewModel.hostname, field: .hostname, kind: .plain)
                field("Port", text: $viewModel.port, field: .port, kind: .number)
                field("Username", text: $viewModel.username, field: .username, kind: .plain)
            }
            Section("Authentication") {
                Picker("Method", selection: Binding(
                    get: {
                        switch viewModel.authenticationMethod {
                        case .password: return "password"
                        case .publicKey: return "key"
                        }
                    },
                    set: { value in
                        if value == "password" {
                            viewModel.setAuthMethod(.password)
                        } else {
                            viewModel.setAuthMethod(.publicKey(keyID: UUID()))
                        }
                    }
                )) {
                    Text("Password").tag("password")
                    Text("SSH Key").tag("key")
                }
                if viewModel.showPasswordField {
                    field("Password", text: $viewModel.password, field: .authenticationMethod, kind: .plain)
                    field("Confirm", text: $viewModel.passwordConfirmation, field: .authenticationMethod, kind: .plain)
                }
            }
            Section("Optional Configuration") {
                field("OpenClaw Dashboard URL", text: $viewModel.openClawDashboardURL, field: .openClawDashboardURL, kind: .plain)
                field("OpenClaw Base Path", text: $viewModel.openClawBasePath, field: .openClawDashboardURL, kind: .plain)
                field("Favorite Remote Path", text: $viewModel.favoriteRemotePath, field: .favoriteRemotePath, kind: .plain)
            }
        }
        .navigationTitle(viewModel.title)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { onFinished(false) }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    Task {
                        let saved = await viewModel.save()
                        if saved != nil { onFinished(true) }
                    }
                }
                .disabled(viewModel.isSaving)
            }
        }
    }

    /// Input styling intent, resolved to platform traits where available.
    private enum FieldKind { case words, plain, number }

    @ViewBuilder
    private func field(
        _ label: String,
        text: Binding<String>,
        field: ValidationIssue.Field,
        kind: FieldKind
    ) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.xxs) {
            textField(label, text: text, kind: kind)
            if let message = viewModel.issue(for: field) {
                Text(message)
                    .font(DSTypography.caption)
                    .foregroundStyle(.red)
                    .accessibilityLabel("\(label) error: \(message)")
            }
        }
    }

    @ViewBuilder
    private func textField(_ label: String, text: Binding<String>, kind: FieldKind) -> some View {
        let base = TextField(label, text: text)
        #if os(iOS)
        switch kind {
        case .words:
            base.textInputAutocapitalization(.words)
        case .plain:
            base.textInputAutocapitalization(.never).autocorrectionDisabled()
        case .number:
            base.keyboardType(.numberPad)
        }
        #else
        base
        #endif
    }
}
