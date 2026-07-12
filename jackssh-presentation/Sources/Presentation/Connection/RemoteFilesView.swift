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
                    isTerminalVisible.toggle()
                } label: {
                    Image(systemName: isTerminalVisible ? "terminal.fill" : "terminal")
                }
                .accessibilityLabel(isTerminalVisible ? "Hide terminal" : "Show terminal")
            }
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
                    .disabled(!file.isDirectory)
                }
                .listStyle(.plain)
            }
        }
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
        }
        .contentShape(Rectangle())
    }

    private var detail: String {
        if file.isDirectory { return "Folder" }
        guard let size = file.size else { return "File" }
        return ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file)
    }
}
