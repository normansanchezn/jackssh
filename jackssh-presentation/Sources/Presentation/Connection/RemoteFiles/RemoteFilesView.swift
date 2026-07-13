import SwiftUI
import Domain
import DesignSystem

/// Remote file browser for one host, backed by the SFTP directory use case.
public struct RemoteFilesView: View {
    @State private var viewModel: RemoteFilesViewModel
    @State private var isTerminalVisible = false
    private let terminalViewModel: TerminalViewModel

    public init(viewModel: RemoteFilesViewModel, terminalViewModel: TerminalViewModel) {
        _viewModel = State(initialValue: viewModel)
        self.terminalViewModel = terminalViewModel
    }

    public var body: some View {
        VStack(spacing: 0) {
            directoryHeader
            content
            if isTerminalVisible {
                Divider()
                TerminalScreen(viewModel: terminalViewModel, embedded: true)
                    .frame(height: 280)
            }
        }
        .navigationTitle("Files")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    if isTerminalVisible {
                        isTerminalVisible = false
                    } else {
                        terminalViewModel.prepareEmbeddedTerminal(startupDirectory: viewModel.path)
                        isTerminalVisible = true
                    }
                } label: {
                    Image(systemName: isTerminalVisible ? "terminal.fill" : "terminal")
                }
                .accessibilityLabel(isTerminalVisible ? "Hide terminal" : "Show terminal")
            }
        }
        .sheet(item: codeFileBinding) { codeFile in
            NavigationStack {
                CodeFileViewer(codeFile: codeFile)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Done") { viewModel.dismissCodeFile() }
                        }
                    }
            }
        }
        .alert("Couldn’t open file", isPresented: fileErrorBinding) {
            Button("OK", role: .cancel) { viewModel.dismissCodeFile() }
        } message: {
            Text(viewModel.fileLoadError ?? "Unknown error")
        }
        .task { await viewModel.load() }
    }

    private var directoryHeader: some View {
        HStack(spacing: DSSpacing.sm) {
            Button {
                Task { await viewModel.goUp() }
            } label: {
                Image(systemName: "arrow.up")
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(.bordered)
            .disabled(viewModel.path == "/")
            .accessibilityLabel("Go to parent folder")

            Text(viewModel.path)
                .font(DSTypography.mono)
                .lineLimit(1)
                .truncationMode(.middle)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                Task { await viewModel.load() }
            } label: {
                Image(systemName: "arrow.clockwise")
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(.bordered)
            .accessibilityLabel("Refresh folder")
        }
        .padding(.horizontal, DSSpacing.lg)
        .padding(.vertical, DSSpacing.sm)
        .background(.bar)
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView("Loading folder…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case let .failed(message):
            ContentUnavailableView(
                "Couldn’t load this folder",
                systemImage: "folder.badge.questionmark",
                description: Text(message)
            )
        case let .loaded(files):
            if files.isEmpty {
                ContentUnavailableView("Empty folder", systemImage: "folder")
            } else {
                List(files, id: \.path) { file in
                    Button {
                        Task { await viewModel.open(file) }
                    } label: {
                        RemoteFileRow(file: file)
                    }
                    .buttonStyle(.plain)
                    .disabled(!file.isDirectory && CodeLanguage.detect(for: file.name) == .plainText)
                }
                .listStyle(.plain)
            }
        }
    }

    private var codeFileBinding: Binding<RemoteFilesViewModel.CodeFile?> {
        Binding(
            get: { viewModel.codeFile },
            set: { if $0 == nil { viewModel.dismissCodeFile() } }
        )
    }

    private var fileErrorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.fileLoadError != nil },
            set: { if !$0 { viewModel.dismissCodeFile() } }
        )
    }
}

private struct RemoteFileRow: View {
    let file: SFTPFileInfo

    var body: some View {
        HStack(spacing: DSSpacing.md) {
            Image(systemName: file.isDirectory ? "folder.fill" : "doc")
                .foregroundStyle(file.isDirectory ? .blue : .secondary)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                Text(file.name)
                    .foregroundStyle(.primary)
                Text(detail)
                    .font(DSTypography.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if file.isDirectory {
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            if !file.isDirectory, CodeLanguage.detect(for: file.name) != .plainText {
                Text(CodeLanguage.detect(for: file.name).rawValue)
                    .font(DSTypography.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .contentShape(Rectangle())
    }

    private var detail: String {
        if file.isDirectory { return "Folder" }
        guard let size = file.size else { return "File" }
        return ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file)
    }
}

private struct CodeFileViewer: View {
    @Environment(\.jacksshTheme) private var theme
    let codeFile: RemoteFilesViewModel.CodeFile

    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(Array(codeFile.content.split(separator: "\n", omittingEmptySubsequences: false).enumerated()), id: \.offset) { index, line in
                    HStack(alignment: .firstTextBaseline, spacing: DSSpacing.md) {
                        Text("\(index + 1)")
                            .foregroundStyle(theme.colors.textTertiary)
                            .frame(minWidth: 34, alignment: .trailing)
                        Text(String(line))
                            .foregroundStyle(theme.colors.textPrimary)
                            .textSelection(.enabled)
                    }
                    .font(DSTypography.mono)
                    .padding(.leading, DSSpacing.xs)
                    .padding(.trailing, DSSpacing.sm)
                    .padding(.vertical, 2)
                }
            }
            .padding(.vertical, DSSpacing.sm)
        }
        .background(theme.colors.background)
        .navigationTitle(codeFile.file.name)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .safeAreaInset(edge: .top) {
            HStack {
                Label(CodeLanguage.detect(for: codeFile.file.name).rawValue, systemImage: "chevron.left.forwardslash.chevron.right")
                    .font(DSTypography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                Spacer()
                Text("Read only")
                    .font(DSTypography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
            }
            .padding(.horizontal, DSSpacing.md)
            .padding(.vertical, DSSpacing.sm)
            .dsGlassSurface()
        }
    }
}

#Preview("Remote files") {
    let dependencies = PreviewFixtures.hostsDependencies()
    return NavigationStack {
        RemoteFilesView(
            viewModel: dependencies.makeRemoteFilesViewModel(PreviewFixtures.host.id, "/var/www"),
            terminalViewModel: dependencies.makeTerminalViewModel(PreviewFixtures.host.id)
        )
    }
    .withJacksshThemeAutomatic()
}
