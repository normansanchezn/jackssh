import SwiftUI
import DesignSystem

/// App root. Owns the `NavigationStack` and maps typed routes to screens.
/// Feature screens that aren't in this build resolve to a placeholder — the
/// architecture and navigation are wired end to end before the feature exists.
public struct RootView: View {
    @State private var authViewModel: AuthViewModel
    @State private var router: AppRouter
    private let homeViewModel: HomeViewModel
    private let hostsDependencies: HostsDependencies

    public init(
        authViewModel: AuthViewModel,
        router: AppRouter,
        homeViewModel: HomeViewModel,
        hostsDependencies: HostsDependencies
    ) {
        _authViewModel = State(initialValue: authViewModel)
        _router = State(initialValue: router)
        self.homeViewModel = homeViewModel
        self.hostsDependencies = hostsDependencies
    }

    public var body: some View {
        DSThemeContainer {
            switch authViewModel.authState {
            case .authenticated:
                NavigationStack(path: $router.path) {
                    HomeView(viewModel: homeViewModel, router: router) {
                        await authViewModel.logout()
                    }
                        .environment(router)
                        .navigationDestination(for: AppRoute.self) { route in
                            destination(for: route)
                                .environment(router)
                        }
                }
            default:
                AuthFlowView(authViewModel: authViewModel)
            }
        }
        .task {
            await authViewModel.checkCurrentUser()
        }
    }

    @ViewBuilder
    private func destination(for route: AppRoute) -> some View {
        switch route {
        case .hosts:
            HostsListView(dependencies: hostsDependencies)
        case let .connecting(hostID):
            if let uuid = UUID(uuidString: hostID) {
                ConnectingHostView(viewModel: hostsDependencies.makeConnectingViewModel(uuid))
            } else {
                ComingSoonView(title: "Invalid host ID")
            }
        case let .connected(hostID):
            if let uuid = UUID(uuidString: hostID) {
                let vm = hostsDependencies.makeConnectedViewModel(uuid)
                ConnectedHostViewContainer(viewModel: vm)
            } else {
                ComingSoonView(title: "Invalid host ID")
            }
        case let .host(id):
            ComingSoonView(title: "Host \(id)")
        case let .openClawSession(id):
            if let uuid = UUID(uuidString: id) {
                OpenClawDashboardView(hostID: uuid, dependencies: hostsDependencies)
            } else {
                ComingSoonView(title: "Invalid host ID")
            }
        case let .serviceLogs(serviceID):
            ComingSoonView(title: "\(serviceID) Logs")
        case let .terminal(hostID):
            TerminalView(hostID: hostID, dependencies: hostsDependencies)
        case let .files(hostID, path):
            if let uuid = UUID(uuidString: hostID) {
                RemoteFilesView(
                    viewModel: hostsDependencies.makeRemoteFilesViewModel(uuid, path),
                    terminalViewModel: hostsDependencies.makeTerminalViewModel(uuid)
                )
            } else {
                ComingSoonView(title: "Invalid host ID")
            }
        }
    }
}

struct ConnectedHostViewContainer: View {
    @State private var viewModel: ConnectedHostViewModel

    init(viewModel: ConnectedHostViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        if let session = viewModel.session, let host = viewModel.host {
            ConnectedHostView(session: session, host: host) {
                await viewModel.disconnect()
            }
        } else if let error = viewModel.loadError {
            ContentUnavailableView(
                "Connection unavailable",
                systemImage: "bolt.slash",
                description: Text(error)
            )
        } else {
            ProgressView()
                .task { await viewModel.load() }
        }
    }
}

/// Placeholder for routes whose feature is not yet implemented.
struct ComingSoonView: View {
    let title: String

    var body: some View {
        DSScreenScaffold(title: title) {
            DSCard {
                Label("Not available in this build", systemImage: "hammer.fill")
                    .font(DSTypography.body)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
