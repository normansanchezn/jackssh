import SwiftUI
import DesignSystem

/// App root. Owns the `NavigationStack` and maps typed routes to screens.
/// Feature screens that aren't in this build resolve to a placeholder — the
/// architecture and navigation are wired end to end before the feature exists.
public struct RootView: View {
    @State private var authViewModel: AuthViewModel
    @State private var router: AppRouter
    @State private var isBootstrapping = true
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
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
            ZStack {
                if isBootstrapping {
                    SplashView()
                        .transition(.opacity.combined(with: .scale(scale: 1.02)))
                } else {
                    switch authViewModel.authState {
                    case .authenticated:
                        if horizontalSizeClass == .regular {
                            IPadAppShell(
                                router: router,
                                homeViewModel: homeViewModel,
                                hostsDependencies: hostsDependencies
                            ) {
                                await authViewModel.logout()
                            }
                            .environment(router)
                        } else {
                            CompactAppShell(
                                router: router,
                                homeViewModel: homeViewModel,
                                hostsDependencies: hostsDependencies
                            ) {
                                await authViewModel.logout()
                            }
                            .environment(router)
                        }
                    default:
                        AuthFlowView(authViewModel: authViewModel)
                    }
                }
            }
            .animation(.easeOut(duration: 0.28), value: isBootstrapping)
        }
        .task {
            await bootstrap()
        }
        .preferredColorScheme(.dark)
    }

    private func bootstrap() async {
        async let sessionCheck: Void = authViewModel.checkCurrentUser()
        async let minimumDisplay: Void = sleepForSplash()
        _ = await (sessionCheck, minimumDisplay)
        isBootstrapping = false
    }

    private func sleepForSplash() async {
        try? await Task.sleep(for: .milliseconds(950))
    }
}

private enum IPadSidebarSelection: Hashable {
    case dashboard
    case hosts
}

private struct CompactAppShell: View {
    @Bindable var router: AppRouter
    let homeViewModel: HomeViewModel
    let hostsDependencies: HostsDependencies
    let onLogout: () async -> Void

    var body: some View {
        NavigationStack(path: $router.path) {
            HomeView(viewModel: homeViewModel, router: router) {
                await onLogout()
            }
            .environment(router)
            .navigationDestination(for: AppRoute.self) { route in
                RootDestinationView(
                    route: route,
                    hostsDependencies: hostsDependencies,
                    homeViewModel: homeViewModel
                )
                .environment(router)
            }
        }
        .safeAreaInset(edge: .bottom) {
            DSFloatingBottomNav(selectedID: selectedID, items: navItems)
                .padding(.horizontal, 22)
                .padding(.bottom, 8)
        }
    }

    private var navItems: [DSBottomNavItem] {
        let session = homeViewModel.activeSession
        return [
            DSBottomNavItem(id: "home", title: "Home", systemImage: "square.grid.2x2") {
                router.popToRoot()
            },
            DSBottomNavItem(id: "hosts", title: "Hosts", systemImage: "server.rack") {
                router.path = [.hosts]
            },
            DSBottomNavItem(id: "shell", title: "Shell", systemImage: "terminal", isEnabled: session != nil) {
                if let session {
                    router.path = [.terminal(hostID: session.hostID.uuidString)]
                }
            },
            DSBottomNavItem(id: "files", title: "Files", systemImage: "folder", isEnabled: session != nil) {
                if let session {
                    router.path = [.files(hostID: session.hostID.uuidString, path: "/")]
                }
            },
            DSBottomNavItem(id: "alerts", title: "Alerts", systemImage: "bell", badgeCount: 2) {
                router.path = [.alerts]
            },
        ]
    }

    private var selectedID: String {
        guard let last = router.path.last else { return "home" }
        switch last {
        case .hosts, .connecting, .connected, .host:
            return "hosts"
        case .terminal:
            return "shell"
        case .files:
            return "files"
        case .alerts:
            return "alerts"
        case .openClawSession, .serviceLogs:
            return "home"
        }
    }
}

private struct IPadAppShell: View {
    @Environment(\.jacksshTheme) private var theme
    @State private var selection: IPadSidebarSelection? = .dashboard
    @State private var columnVisibility: NavigationSplitViewVisibility = .all

    @Bindable var router: AppRouter
    let homeViewModel: HomeViewModel
    let hostsDependencies: HostsDependencies
    let onLogout: () async -> Void

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            List(selection: $selection) {
                Section("Operations") {
                    Label("Dashboard", systemImage: "gauge.with.dots.needle.67percent")
                        .tag(IPadSidebarSelection.dashboard)
                    Label("Hosts", systemImage: "server.rack")
                        .tag(IPadSidebarSelection.hosts)
                }
            }
            .navigationTitle("JackSSH")
            .navigationSplitViewColumnWidth(min: 220, ideal: 260, max: 320)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button(role: .destructive) {
                            Task { await onLogout() }
                        } label: {
                            Label("Log out", systemImage: "rectangle.portrait.and.arrow.right")
                        }
                    } label: {
                        Image(systemName: "person.crop.circle")
                    }
                    .accessibilityLabel("Account options")
                }
            }
        } detail: {
            NavigationStack(path: $router.path) {
                selectedRoot
                    .environment(router)
                    .navigationDestination(for: AppRoute.self) { route in
                        RootDestinationView(route: route, hostsDependencies: hostsDependencies)
                            .environment(router)
                    }
            }
        }
        .tint(theme.colors.primary600)
        .onChange(of: selection) { _, _ in
            router.popToRoot()
        }
        .onChange(of: router.path) { _, path in
            if path.last == .hosts {
                selection = .hosts
            }
        }
    }

    @ViewBuilder
    private var selectedRoot: some View {
        switch selection ?? .dashboard {
        case .dashboard:
            HomeView(
                viewModel: homeViewModel,
                router: router,
                showsAccountMenu: false,
                onLogout: onLogout
            )
        case .hosts:
            HostsListView(dependencies: hostsDependencies)
        }
    }
}

private struct RootDestinationView: View {
    let route: AppRoute
    let hostsDependencies: HostsDependencies
    let homeViewModel: HomeViewModel?

    init(route: AppRoute, hostsDependencies: HostsDependencies, homeViewModel: HomeViewModel? = nil) {
        self.route = route
        self.hostsDependencies = hostsDependencies
        self.homeViewModel = homeViewModel
    }

    var body: some View {
        destination
    }

    @ViewBuilder
    private var destination: some View {
        switch route {
        case .hosts:
            HostsListView(dependencies: hostsDependencies)
        case .alerts:
            if let homeViewModel {
                AlertsView(viewModel: homeViewModel)
            } else {
                ComingSoonView(title: "Alerts")
            }
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
                OpenClawDashboardView(viewModel: hostsDependencies.makeOpenClawDashboardViewModel(uuid))
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
