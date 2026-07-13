import SwiftUI
import Domain
import DesignSystem

/// Declarative Home screen. All logic lives in `HomeViewModel`; this view only
/// renders state and forwards navigation intents to the router.
public struct HomeView: View {
    @State private var viewModel: HomeViewModel
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.jacksshTheme) private var theme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private let router: AppRouter
    private let onLogout: () async -> Void
    private let showsAccountMenu: Bool
    
    public init(
        viewModel: HomeViewModel,
        router: AppRouter,
        showsAccountMenu: Bool = true,
        onLogout: @escaping () async -> Void = {}
    ) {
        _viewModel = State(initialValue: viewModel)
        self.router = router
        self.showsAccountMenu = showsAccountMenu
        self.onLogout = onLogout
    }
    
    public var body: some View {
        DSBackground(showGrid: true) {
            ScrollView {
                VStack(alignment: .leading, spacing: DSSpacing.lg) {
                    Text("JackSSH")
                        .font(.system(.title2, weight: .bold))
                        .foregroundStyle(theme.colors.textPrimary)
                        .padding(.top, DSSpacing.md)

                    switch viewModel.state {
                    case .idle, .loading:
                        loadingView
                    case let .loaded(status):
                        loadedView(status)
                    case let .failed(error):
                        errorView(error)
                    }
                }
                .padding(.horizontal, DSSpacing.lg)
                .padding(.bottom, showsAccountMenu ? 96 : DSSpacing.xl)
            }
        }
        .navigationTitle("")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .task { await viewModel.load() }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else { return }
            Task { await viewModel.load() }
        }
        .toolbar {
            if showsAccountMenu {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button(role: .destructive) {
                            Task { await onLogout() }
                        } label: {
                            Label("Log out", systemImage: "rectangle.portrait.and.arrow.right")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                    .accessibilityLabel("Account options")
                }
            }
        }
    }
    
    private var loadingView: some View {
        DSGlassSurface {
            HStack(spacing: DSSpacing.md) {
                ProgressView()
                Text("Checking status…")
                    .font(DSTypography.body)
            }
        }
        .accessibilityLabel("Checking status")
    }
    
    private func loadedView(_ status: HomeStatus) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.lg) {
            metrics(status)
            statusSection(status)
            manageHostsCard(activeSession: viewModel.activeSession)
            recentActivity(status.recentActivity)
        }
        .frame(maxWidth: horizontalSizeClass == .regular ? 780 : .infinity, alignment: .leading)
    }

    private func metrics(_ status: HomeStatus) -> some View {
        HStack(spacing: DSSpacing.sm) {
            DSMetricTile(value: "3", label: "Hosts", caption: "active", tone: .positive)
            DSMetricTile(value: "\(status.recentActivity.count)", label: "Alerts", caption: "unread", tone: status.recentActivity.isEmpty ? .neutral : .warning)
            DSMetricTile(value: status.privateNetworkOnline ? "Up" : "Down", label: "VPN", caption: "status", tone: status.privateNetworkOnline ? .positive : .critical)
        }
    }
    
    private func statusSection(_ status: HomeStatus) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
            Text("INFRASTRUCTURE")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(theme.colors.textTertiary)
                .accessibilityAddTraits(.isHeader)
            
            DSGlassSurface {
                VStack(spacing: DSSpacing.sm) {
                    DSOpsStatusRow(
                        systemImage: "network",
                        title: "Private network",
                        subtitle: "secure route",
                        tone: status.privateNetworkOnline ? .positive : .critical,
                        statusLabel: status.privateNetworkOnline ? "Online" : "Down"
                    )
                    DSOpsStatusRow(
                        systemImage: "server.rack",
                        title: "VPS · Production",
                        subtitle: "root@108.174.154.104",
                        tone: status.vps.tone,
                        statusLabel: status.vps.label
                    )
                    DSOpsStatusRow(
                        systemImage: "sparkles",
                        title: "OpenClaw",
                        subtitle: "dashboard bridge",
                        tone: status.openClaw.tone,
                        statusLabel: status.openClaw.label
                    )
#if os(macOS)
                    DSOpsStatusRow(
                        systemImage: "cpu",
                        title: "Ollama",
                        tone: status.ollama.tone,
                        statusLabel: status.ollama.label
                    )
#endif
                }
                .padding(DSSpacing.md)
            }
        }
    }
    
    private func manageHostsCard(activeSession: ConnectedHostSession?) -> some View {
        Button {
            router.push(.hosts)
        } label: {
            VStack(alignment: .leading, spacing: DSSpacing.md) {
                Text("HOSTS")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(theme.colors.textTertiary)

                DSOpsStatusRow(
                    systemImage: "server.rack",
                    title: activeSession.map { $0.hostname } ?? "Manage hosts",
                    subtitle: activeSession.map { "\($0.username)@\($0.hostname):\($0.port)" } ?? "Configure and connect to your servers",
                    tone: activeSession == nil ? .neutral : .positive,
                    statusLabel: activeSession == nil ? "Open" : "Connected"
                )
            }
            .padding(DSSpacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .dsGlassSurface()
        }
        .buttonStyle(.plain)
        .accessibilityHint("Opens your saved hosts")
    }

    private func recentActivity(_ events: [ActivityEvent]) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
            Text("RECENT")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(theme.colors.textTertiary)

            DSGlassSurface {
                VStack(alignment: .leading, spacing: DSSpacing.sm) {
                    ForEach(events.prefix(3)) { event in
                        DSOpsStatusRow(
                            systemImage: "bell",
                            title: event.title,
                            subtitle: event.timestamp.formatted(date: .omitted, time: .shortened),
                            tone: event.state.tone,
                            statusLabel: event.state.label
                        )
                    }
                    if events.isEmpty {
                        Text("No alerts recorded")
                            .font(DSTypography.caption)
                            .foregroundStyle(theme.colors.textSecondary)
                            .padding(DSSpacing.md)
                    }
                }
                .padding(DSSpacing.md)
            }
        }
    }
    
    private func errorView(_ error: DomainError) -> some View {
        DSCard {
            VStack(alignment: .leading, spacing: DSSpacing.md) {
                Label("Couldn’t load status", systemImage: "exclamationmark.triangle.fill")
                    .font(DSTypography.sectionTitle)
                    .foregroundStyle(.orange)
                Button("Retry") {
                    Task { await viewModel.load() }
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
}


#Preview("Home") {
    let router = AppRouter()
    return NavigationStack {
        HomeView(viewModel: PreviewFixtures.homeViewModel(), router: router)
            .environment(router)
    }
    .withJacksshThemeAutomatic()
}
