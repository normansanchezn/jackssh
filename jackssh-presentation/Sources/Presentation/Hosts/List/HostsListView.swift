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
                    Text("\(hosts.count) SAVED")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(theme.colors.textTertiary)

                    hostsCollection(hosts)
                    
                    Color.clear.frame(height: 96)
                }
                .padding(DSSpacing.lg)
                .frame(maxWidth: horizontalSizeClass == .regular ? 900 : .infinity, alignment: .leading)
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
                    DSGlassSurface {
                        hostRow(host)
                            .padding(.horizontal, DSSpacing.md)
                            .padding(.vertical, DSSpacing.sm)
                    }
                }
            }
        } else {
            DSGlassSurface {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(hosts.enumerated()), id: \.element.id) { index, host in
                        hostRow(host)
                        if index < hosts.count - 1 {
                            Divider()
                                .overlay(theme.colors.border.opacity(0.5))
                                .padding(.leading, 32)
                        }
                    }
                }
                .padding(.horizontal, DSSpacing.md)
                .padding(.vertical, DSSpacing.sm)
            }
        }
    }

    private func hostRow(_ host: Domain.Host) -> some View {
        HostRowLabel(host: host)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .simultaneousGesture(TapGesture().onEnded {
                router.push(.connecting(hostID: host.id.uuidString))
            })
            .contextMenu {
                Button("Edit", systemImage: "pencil") {
                    editorTarget = .edit(host)
                }
                Button("Delete", systemImage: "trash", role: .destructive) {
                    pendingDeletion = host
                }
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
    
    var body: some View {
        HStack(alignment: .center, spacing: DSSpacing.sm) {
            Circle()
                .fill(host.isFavorite ? theme.colors.statusPending : theme.colors.statusConnected)
                .frame(width: 6, height: 6)
            
            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                Text(host.name)
                    .font(DSTypography.caption.weight(.semibold))
                    .foregroundStyle(theme.colors.textPrimary)
                    .lineLimit(1)
                Text("\(host.username)@\(host.hostname):\(host.port)")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(theme.colors.textSecondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
                Text(lastConnectionLabel)
                    .font(.system(size: 9))
                    .foregroundStyle(theme.colors.textTertiary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Text(host.isFavorite ? "Idle" : "Connected")
                .font(.system(size: 9, weight: .semibold, design: .monospaced))
                .foregroundStyle(host.isFavorite ? theme.colors.statusPending : theme.colors.statusConnected)

            Image(systemName: "chevron.right")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(theme.colors.textTertiary)
        }
        .padding(.vertical, DSSpacing.sm)
        .contentShape(Rectangle())
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
