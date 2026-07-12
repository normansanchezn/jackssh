import SwiftUI
import Domain
import DesignSystem

/// Hosts list: create, edit, delete (with confirmation). Tapping a host
/// navigates to the connection flow. Swiping opens edit.
public struct HostsListView: View {
    @State private var viewModel: HostsViewModel
    @State private var editorTarget: EditorTarget?
    @State private var pendingDeletion: Domain.Host?
    @Environment(\.jacksshTheme) private var theme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(AppRouter.self) private var router
    
    private let dependencies: HostsDependencies
    
    public init(dependencies: HostsDependencies) {
        self.dependencies = dependencies
        _viewModel = State(initialValue: dependencies.makeListViewModel())
    }
    
    public var body: some View {
        DSBackground(showGrid: true) {
            content
        }
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
            createHost(host: target.host)
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
    
    private func createHost(host: Domain.Host?) -> some View {
        NavigationStack {
            HostEditorView(
                viewModel: dependencies.makeEditorViewModel(host),
                onFinished: { saved in
                    editorTarget = nil
                    if saved { Task { await viewModel.load() } }
                }
            )
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
                VStack(alignment: .leading, spacing: DSSpacing.md) {
                    Text("\(hosts.count) saved \(hosts.count == 1 ? "host" : "hosts")")
                        .font(DSTypography.caption)
                        .foregroundStyle(.secondary)

                    hostsCollection(hosts)
                    
                    Color.clear.frame(height: DSSpacing.xl)
                }
                .padding(DSSpacing.lg)
                .frame(maxWidth: horizontalSizeClass == .regular ? 1080 : .infinity, alignment: .leading)
            }
        }
    }

    @ViewBuilder
    private func hostsCollection(_ hosts: [Domain.Host]) -> some View {
        if horizontalSizeClass == .regular {
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 320, maximum: 460), spacing: DSSpacing.md, alignment: .top)],
                alignment: .leading,
                spacing: DSSpacing.md
            ) {
                ForEach(hosts) { host in
                    hostRow(host)
                }
            }
        } else {
            LazyVStack(alignment: .leading, spacing: DSSpacing.md) {
                ForEach(hosts) { host in
                    hostRow(host)
                }
            }
        }
    }

    private func hostRow(_ host: Domain.Host) -> some View {
        HostRowLabel(host: host)
            .overlay(alignment: .topTrailing) {
                optionButton(host: host)
            }
            .onTapGesture {
                router.push(.connecting(hostID: host.id.uuidString))
            }
    }
    
    private func optionButton(host: Domain.Host) -> some View {
        Menu {
            Button("Edit", systemImage: "pencil", action: {
                editorTarget = .edit(host)
            })
            Button("Delete", systemImage: "trash", role: .destructive, action: {
                pendingDeletion = host
            })
        } label: {
            Image(systemName: "ellipsis.circle.fill")
                .font(.title3)
                .foregroundStyle(theme.colors.textSecondary)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .padding([.top, .trailing], DSSpacing.md)
        .accessibilityLabel("More options for \(host.name)")
        .buttonStyle(.plain)
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
    
    var body: some View {
        HStack(alignment: .top, spacing: DSSpacing.md) {
            DSIconTile(
                symbol: host.isFavorite ? "star.fill" : "server.rack",
                tint: host.isFavorite ? theme.colors.warning : theme.colors.primary600
            )
            
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
            
        }
        .padding(DSSpacing.md)
        .dsGlassSurface()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Connect to \(host.name), \(host.username) at \(host.hostname) port \(host.port)")
        .accessibilityHint("Tap to connect")
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
