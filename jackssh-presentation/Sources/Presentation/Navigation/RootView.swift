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
                                hostsDependencies: hostsDependencies,
                                dashboardTitle: dashboardTitle
                            ) {
                                await authViewModel.logout()
                            }
                            .environment(router)
                        } else {
                            CompactAppShell(
                                router: router,
                                homeViewModel: homeViewModel,
                                hostsDependencies: hostsDependencies,
                                dashboardTitle: dashboardTitle
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

    private var dashboardTitle: String {
        if case let .authenticated(user) = authViewModel.authState {
            let name = user.displayName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            return name.isEmpty ? "Gest test" : name
        }
        return "Gest test"
    }
}

private enum IPadSidebarSelection: Hashable {
    case dashboard
    case openClaw
    case hosts
    case terminal
    case files
    case alerts
}

private struct CompactAppShell: View {
    @Bindable var router: AppRouter
    @State private var isAddHostSheetPresented = false
    let homeViewModel: HomeViewModel
    let hostsDependencies: HostsDependencies
    let dashboardTitle: String
    let onLogout: () async -> Void

    var body: some View {
        NavigationStack(path: $router.path) {
            HomeView(viewModel: homeViewModel, router: router, dashboardTitle: dashboardTitle) {
                isAddHostSheetPresented = true
            } onLogout: {
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
        .sheet(isPresented: $isAddHostSheetPresented) {
            NavigationStack {
                HostEditorView(viewModel: hostsDependencies.makeEditorViewModel(nil)) { saved in
                    isAddHostSheetPresented = false
                    if saved {
                        Task { await homeViewModel.load() }
                    }
                }
            }
        }
    }

    private var navItems: [DSBottomNavItem] {
        var items = [
            DSBottomNavItem(id: "home", title: "Dashboard", systemImage: "square.grid.2x2") {
                router.popToRoot()
            }
        ]

        guard homeViewModel.hasConfiguredHosts else {
            return items
        }

        items.append(
            DSBottomNavItem(id: "hosts", title: "Hosts", systemImage: "server.rack") {
                router.path = [.hosts]
            }
        )

        guard let session = homeViewModel.activeSession else {
            return items
        }

        if homeViewModel.hasOpenClawForActiveSession {
            items.append(
                DSBottomNavItem(id: "openclaw", title: "OpenClaw", systemImage: "point.topleft.down.curvedto.point.bottomright.up") {
                    router.path = [.openClawSession(id: session.hostID.uuidString)]
                }
            )
        }

        items.append(contentsOf: [
            DSBottomNavItem(id: "shell", title: "Shell", systemImage: "terminal") {
                router.path = [.terminal(hostID: session.hostID.uuidString)]
            },
            DSBottomNavItem(id: "files", title: "Files", systemImage: "folder") {
                router.path = [.files(hostID: session.hostID.uuidString, path: "/")]
            },
            DSBottomNavItem(id: "alerts", title: "Alerts", systemImage: "bell", badgeCount: 2) {
                router.path = [.alerts]
            },
        ])
        return items
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
        case .openClawSession:
            return "openclaw"
        case .serviceLogs:
            return "home"
        }
    }
}

private struct IPadAppShell: View {
    @Environment(\.jacksshTheme) private var theme
    @State private var selection: IPadSidebarSelection? = .dashboard
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    @State private var isLogoutConfirmationPresented = false

    @Bindable var router: AppRouter
    let homeViewModel: HomeViewModel
    let hostsDependencies: HostsDependencies
    let dashboardTitle: String
    let onLogout: () async -> Void

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            VStack(alignment: .leading, spacing: DSSpacing.lg) {
                Image("logo_jack_ssh", bundle: .module)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 112)
                    .padding(.top, DSSpacing.md)

                VStack(alignment: .leading, spacing: DSSpacing.xs) {
                    sidebarButton(.dashboard, title: "Dashboard", systemImage: "gauge.with.dots.needle.67percent")

                    if homeViewModel.hasConfiguredHosts {
                        sidebarButton(.hosts, title: "Hosts", systemImage: "server.rack")
                    }

                    if homeViewModel.activeSession != nil {
                        if homeViewModel.hasOpenClawForActiveSession {
                            sidebarButton(.openClaw, title: "OpenClaw", systemImage: "point.topleft.down.curvedto.point.bottomright.up")
                        }
                        sidebarButton(.terminal, title: "Terminal", systemImage: "terminal")
                        sidebarButton(.files, title: "Explorador", systemImage: "folder")
                        sidebarButton(.alerts, title: "Notificaciones", systemImage: "bell")
                    }
                }

                Spacer()

                Button(role: .destructive) {
                    isLogoutConfirmationPresented = true
                } label: {
                    Label("Cerrar sesión", systemImage: "rectangle.portrait.and.arrow.right")
                        .font(DSTypography.caption.weight(.semibold))
                        .foregroundStyle(theme.colors.statusDisconnected)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, DSSpacing.md)
                        .padding(.vertical, DSSpacing.sm)
                        .background(theme.colors.statusDisconnected.opacity(0.12), in: RoundedRectangle(cornerRadius: DSRadius.sm, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: DSRadius.sm, style: .continuous)
                                .stroke(theme.colors.statusDisconnected.opacity(0.35), lineWidth: 1)
                        }
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, DSSpacing.lg)
            .padding(.bottom, DSSpacing.lg)
            .background(theme.colors.background)
            .navigationSplitViewColumnWidth(min: 220, ideal: 260, max: 320)
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
            } else if case .openClawSession = path.last {
                selection = .openClaw
            }
        }
        .onChange(of: homeViewModel.activeSession) { _, session in
            if session == nil, selection != .dashboard {
                selection = .dashboard
                router.popToRoot()
            }
        }
        .confirmationDialog(
            "¿Cerrar sesión?",
            isPresented: $isLogoutConfirmationPresented,
            titleVisibility: .visible
        ) {
            Button("Cerrar sesión", role: .destructive) {
                Task { await onLogout() }
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Se cerrará tu sesión de JackSSH en este dispositivo.")
        }
    }

    private func sidebarButton(_ item: IPadSidebarSelection, title: String, systemImage: String) -> some View {
        Button {
            selection = item
            router.popToRoot()
        } label: {
            Label(title, systemImage: systemImage)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(selection == item ? theme.colors.primary600 : theme.colors.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, DSSpacing.sm)
                .padding(.vertical, 9)
                .background {
                    if selection == item {
                        RoundedRectangle(cornerRadius: DSRadius.sm, style: .continuous)
                            .fill(theme.colors.primary600.opacity(0.14))
                    }
                }
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var selectedRoot: some View {
        switch selection ?? .dashboard {
        case .dashboard:
            HomeView(
                viewModel: homeViewModel,
                router: router,
                dashboardTitle: dashboardTitle,
                showsAccountMenu: false,
                onLogout: onLogout
            )
        case .openClaw:
            if let session = homeViewModel.activeSession {
                OpenClawDashboardView(viewModel: hostsDependencies.makeOpenClawDashboardViewModel(session.hostID))
            } else {
                HomeView(viewModel: homeViewModel, router: router, dashboardTitle: dashboardTitle, showsAccountMenu: false, onLogout: onLogout)
            }
        case .hosts:
            HostsListView(dependencies: hostsDependencies)
        case .terminal:
            if let session = homeViewModel.activeSession {
                TerminalView(hostID: session.hostID.uuidString, dependencies: hostsDependencies)
            } else {
                HomeView(viewModel: homeViewModel, router: router, dashboardTitle: dashboardTitle, showsAccountMenu: false, onLogout: onLogout)
            }
        case .files:
            if let session = homeViewModel.activeSession {
                RemoteFilesView(
                    viewModel: hostsDependencies.makeRemoteFilesViewModel(session.hostID, "/"),
                    terminalViewModel: hostsDependencies.makeTerminalViewModel(session.hostID)
                )
            } else {
                HomeView(viewModel: homeViewModel, router: router, dashboardTitle: dashboardTitle, showsAccountMenu: false, onLogout: onLogout)
            }
        case .alerts:
            AlertsView(viewModel: homeViewModel)
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
