import SwiftUI
import Domain
import DesignSystem

/// Hosts list: create, edit, delete (with confirmation). Tapping a host
/// navigates to the connection flow. Swiping opens edit.
public struct HostsListView: View {
    @State private var viewModel: HostsViewModel
    @State private var editorTarget: EditorTarget?
    @State private var pendingDeletion: Domain.Host?
    @Environment(AppRouter.self) private var router

    private let dependencies: HostsDependencies

    public init(dependencies: HostsDependencies) {
        self.dependencies = dependencies
        _viewModel = State(initialValue: dependencies.makeListViewModel())
    }

    public var body: some View {
        content
            .navigationTitle("Hosts")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        editorTarget = .new
                    } label: {
                        Label("Add Host", systemImage: "plus")
                    }
                }
            }
            .task { await viewModel.load() }
            .sheet(item: $editorTarget) { target in
                NavigationStack {
                    HostEditorView(
                        viewModel: dependencies.makeEditorViewModel(target.host),
                        onFinished: { saved in
                            editorTarget = nil
                            if saved { Task { await viewModel.load() } }
                        }
                    )
                }
            }
            .confirmationDialog(
                "Delete this host?",
                isPresented: deletionBinding,
                titleVisibility: .visible,
                presenting: pendingDeletion
            ) { host in
                Button("Delete \(host.name)", role: .destructive) {
                    Task { await viewModel.delete(id: host.id) }
                }
                Button("Cancel", role: .cancel) {}
            } message: { _ in
                Text("This removes the host and its stored credentials. This cannot be undone.")
            }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView("Loading hosts…")
        case let .failed(error):
            ContentUnavailableView(
                "Couldn’t load hosts",
                systemImage: "exclamationmark.triangle",
                description: Text(error == .offline ? "You appear to be offline." : "Please try again.")
            )
        case let .loaded(hosts) where hosts.isEmpty:
            ContentUnavailableView {
                Label("No hosts yet", systemImage: "server.rack")
            } description: {
                Text("Add a host to start managing connections.")
            } actions: {
                Button("Add Host") { editorTarget = .new }
                    .buttonStyle(.borderedProminent)
            }
        case let .loaded(hosts):
            ScrollView {
                LazyVStack(alignment: .leading, spacing: DSSpacing.md) {
                    Text("\(hosts.count) saved \(hosts.count == 1 ? "host" : "hosts")")
                        .font(DSTypography.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, DSSpacing.lg)
                        .padding(.top, DSSpacing.sm)

                    ForEach(hosts) { host in
                        HostRowLabel(
                            host: host,
                            onConnect: { router.push(.connecting(hostID: host.id.uuidString)) },
                            onEdit: { editorTarget = .edit(host) },
                            onDelete: { pendingDeletion = host }
                        )
                        .padding(.horizontal, DSSpacing.lg)
                    }
                }
            }
            .background(Color.clear)
        }
    }

    private var deletionBinding: Binding<Bool> {
        Binding(
            get: { pendingDeletion != nil },
            set: { if !$0 { pendingDeletion = nil } }
        )
    }
}

/// Sheet target — distinguishes "new" from "edit an existing host".
private enum EditorTarget: Identifiable {
    case new
    case edit(Domain.Host)

    var id: String {
        switch self {
        case .new: return "new"
        case let .edit(host): return host.id.uuidString
        }
    }

    var host: Domain.Host? {
        switch self {
        case .new: return nil
        case let .edit(host): return host
        }
    }
}

private struct HostRowLabel: View {
    @Environment(\.jacksshTheme) private var theme
    let host: Domain.Host
    let onConnect: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: DSSpacing.md) {
            DSIconTile(
                symbol: host.isFavorite ? "star.fill" : "server.rack",
                tint: host.isFavorite ? theme.colors.warning : theme.colors.primary600
            )

            Button(action: onConnect) {
                VStack(alignment: .leading, spacing: DSSpacing.xs) {
                    Text(host.name)
                        .font(DSTypography.sectionTitle)
                        .foregroundStyle(theme.colors.textPrimary)
                        .lineLimit(1)
                    Text("\(host.username)@\(host.hostname):\(host.port)")
                        .font(DSTypography.mono)
                        .foregroundStyle(theme.colors.textSecondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                    Text(lastConnectionLabel)
                        .font(DSTypography.caption)
                        .foregroundStyle(theme.colors.textTertiary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            VStack(spacing: DSSpacing.xs) {
                Button(action: onConnect) {
                    Image(systemName: "arrow.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(theme.colors.textInverse)
                        .frame(width: 32, height: 32)
                        .background(theme.colors.primary600, in: Circle())
                }
                .accessibilityLabel("Connect to \(host.name)")

                Menu {
                    Button("Edit", systemImage: "pencil", action: onEdit)
                    Button("Delete", systemImage: "trash", role: .destructive, action: onDelete)
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(theme.colors.textTertiary)
                        .frame(width: 32, height: 24)
                }
                .accessibilityLabel("More options for \(host.name)")
            }
        }
        .padding(DSSpacing.md)
        .dsGlassSurface()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(host.name), \(host.username) at \(host.hostname) port \(host.port)")
    }

    private var lastConnectionLabel: String {
        guard let date = host.lastSuccessfulConnection else { return "Not connected yet" }
        return "Last connected \(date.formatted(date: .abbreviated, time: .shortened))"
    }
}


#Preview("Hosts") {
    let router = AppRouter()
    return NavigationStack {
        HostsListView(dependencies: PreviewFixtures.hostsDependencies())
            .environment(router)
    }
    .withJacksshThemeAutomatic()
}
