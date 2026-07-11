import SwiftUI
import DesignSystem

/// App root. Owns the `NavigationStack` and maps typed routes to screens.
/// Feature screens that aren't in this build resolve to a placeholder — the
/// architecture and navigation are wired end to end before the feature exists.
public struct RootView: View {
    @State private var router: AppRouter
    private let homeViewModel: HomeViewModel
    private let hostsDependencies: HostsDependencies

    public init(
        router: AppRouter,
        homeViewModel: HomeViewModel,
        hostsDependencies: HostsDependencies
    ) {
        _router = State(initialValue: router)
        self.homeViewModel = homeViewModel
        self.hostsDependencies = hostsDependencies
    }

    public var body: some View {
        NavigationStack(path: $router.path) {
            HomeView(viewModel: homeViewModel, router: router)
                .navigationDestination(for: AppRoute.self) { route in
                    destination(for: route)
                }
        }
    }

    @ViewBuilder
    private func destination(for route: AppRoute) -> some View {
        switch route {
        case .hosts:
            HostsListView(dependencies: hostsDependencies)
        case let .host(id):
            ComingSoonView(title: "Host \(id)")
        case let .openClawSession(id):
            ComingSoonView(title: "OpenClaw Session \(id)")
        case let .serviceLogs(serviceID):
            ComingSoonView(title: "\(serviceID) Logs")
        case let .terminal(hostID):
            ComingSoonView(title: "Terminal \(hostID)")
        case let .files(hostID, path):
            ComingSoonView(title: "Files \(hostID):\(path)")
        }
    }
}

/// Placeholder for routes whose feature is not yet implemented.
struct ComingSoonView: View {
    let title: String

    var body: some View {
        ScreenScaffold(title: title) {
            DSCard {
                Label("Not available in this build", systemImage: "hammer.fill")
                    .font(DSTypography.body)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
