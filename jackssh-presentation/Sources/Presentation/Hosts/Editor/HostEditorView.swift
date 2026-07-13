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
                    secureField("Password", text: $viewModel.password, field: .authenticationMethod)
                    secureField("Confirm", text: $viewModel.passwordConfirmation, field: .authenticationMethod)
                    Text("Stored only in this device Keychain. Hosts synced from Supabase need the password saved once per device.")
                        .font(DSTypography.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Section("OpenClaw Configuration") {
                field("Host", text: $viewModel.openClawHost, field: .openClawHost, kind: .plain)
                field("Port", text: $viewModel.openClawPort, field: .openClawPort, kind: .number)
                Picker("Scheme", selection: $viewModel.openClawScheme) {
                    Text("HTTP").tag("http")
                    Text("HTTPS").tag("https")
                }
                field("Base Path", text: $viewModel.openClawBasePath, field: .openClawBasePath, kind: .plain)
            }
            Section("Project Settings") {
                HStack(spacing: DSSpacing.sm) {
                    field("Favorite Remote Path", text: $viewModel.favoriteRemotePath, field: .favoriteRemotePath, kind: .plain)
                    Button {
                        viewModel.addFavoriteRemotePath()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22, weight: .semibold))
                    }
                    .buttonStyle(.plain)
                    .disabled(viewModel.favoriteRemotePath.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .accessibilityLabel("Add favorite remote path")
                }

                if !viewModel.favoriteRemotePaths.isEmpty {
                    ForEach(viewModel.favoriteRemotePaths, id: \.self) { path in
                        HStack(spacing: DSSpacing.sm) {
                            Image(systemName: "folder")
                                .foregroundStyle(.secondary)
                            Text(path)
                                .font(DSTypography.mono)
                                .lineLimit(1)
                                .truncationMode(.middle)
                            Spacer()
                            Button(role: .destructive) {
                                viewModel.removeFavoriteRemotePath(path)
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Remove \(path)")
                        }
                    }
                }
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

    private func secureField(
        _ label: String,
        text: Binding<String>,
        field: ValidationIssue.Field
    ) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.xxs) {
            SecureField(label, text: text)
                #if os(iOS)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                #endif
            if let message = viewModel.issue(for: field) {
                Text(message)
                    .font(DSTypography.caption)
                    .foregroundStyle(.red)
                    .accessibilityLabel("\(label) error: \(message)")
            }
        }
    }
}

#Preview("Host editor") {
    NavigationStack {
        HostEditorView(
            viewModel: PreviewFixtures.hostsDependencies().makeEditorViewModel(PreviewFixtures.host),
            onFinished: { _ in }
        )
    }
    .withJacksshThemeAutomatic()
}
