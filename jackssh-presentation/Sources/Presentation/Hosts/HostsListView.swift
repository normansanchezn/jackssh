import SwiftUI
import Domain
import DesignSystem

/// Hosts list: create, edit, delete (with confirmation). Declarative — all
/// behavior lives in `HostsViewModel` / `HostEditorViewModel`.
public struct HostsListView: View {
    @State private var viewModel: HostsViewModel
    @State private var editorTarget: EditorTarget?
    @State private var pendingDeletion: Domain.Host?

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
            List {
                ForEach(hosts) { host in
                    Button {
                        editorTarget = .edit(host)
                    } label: {
                        HostRowLabel(host: host)
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            pendingDeletion = host
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
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
    let host: Domain.Host

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                HStack {
                    Text(host.name)
                        .font(DSTypography.body)
                        .foregroundStyle(.primary)
                    if host.isFavorite {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)
                    }
                }
                Text("\(host.username)@\(host.hostname):\(host.port)")
                    .font(DSTypography.caption)
                    .foregroundStyle(.secondary)
                if let lastConnection = host.lastSuccessfulConnection {
                    Text("Last: \(lastConnection.formatted(date: .abbreviated, time: .shortened))")
                        .font(DSTypography.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            Spacer()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(host.name), \(host.username) at \(host.hostname) port \(host.port)")
    }
}
