import SwiftUI
import Domain
import DesignSystem

/// Declarative Home screen. All logic lives in `HomeViewModel`; this view only
/// renders state and forwards navigation intents to the router.
public struct HomeView: View {
    @State private var viewModel: HomeViewModel
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.jacksshTheme) private var theme
    private let router: AppRouter
    private let onLogout: () async -> Void
    
    public init(
        viewModel: HomeViewModel,
        router: AppRouter,
        onLogout: @escaping () async -> Void = {}
    ) {
        _viewModel = State(initialValue: viewModel)
        self.router = router
        self.onLogout = onLogout
    }
    
    public var body: some View {
        DSScreenScaffold(title: "JackSSH") {
            switch viewModel.state {
            case .idle, .loading:
                loadingView
            case let .loaded(status):
                loadedView(status)
            case let .failed(error):
                errorView(error)
            }
        }
        .task { await viewModel.load() }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else { return }
            Task { await viewModel.load() }
        }
        .toolbar {
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
    
    private var loadingView: some View {
        DSCard {
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
            manageHostsCard(activeSession: viewModel.activeSession)
            statusSection(status)
        }
    }
    
    private func statusSection(_ status: HomeStatus) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
            Text("Status")
                .font(DSTypography.sectionTitle)
                .accessibilityAddTraits(.isHeader)
            
            DSGlassSurface {
                VStack(spacing: 8) {
                    DSStatusRow(
                        systemImage: "network",
                        title: "Private network",
                        tone: status.privateNetworkOnline ? .positive : .critical,
                        statusLabel: status.privateNetworkOnline ? "Connected" : "Down"
                    ).padding(.vertical, 6)
                    Divider()
                    DSStatusRow(
                        systemImage: "server.rack",
                        title: "VPS",
                        tone: status.vps.tone,
                        statusLabel: status.vps.label
                    ).padding(.vertical, 6)
                    Divider()
                    DSStatusRow(
                        systemImage: "sparkles",
                        title: "OpenClaw",
                        tone: status.openClaw.tone,
                        statusLabel: status.openClaw.label
                    ).padding(.vertical, 6)
#if os(macOS)
                    Divider()
                    DSStatusRow(
                        systemImage: "cpu",
                        title: "Ollama",
                        tone: status.ollama.tone,
                        statusLabel: status.ollama.label
                    ).padding(.vertical, 6)
#endif
                }
                .padding(.horizontal, DSSpacing.lg)
                .padding(.vertical, DSSpacing.sm)
            }
        }
    }
    
    private func manageHostsCard(activeSession: ConnectedHostSession?) -> some View {
        Button {
            router.push(.hosts)
        } label: {
            HStack(spacing: DSSpacing.md) {
                DSIconTile(symbol: "server.rack", tint: theme.colors.primary600, size: 44)
                
                VStack(alignment: .leading, spacing: DSSpacing.xs) {
                    Text("Manage hosts")
                        .font(DSTypography.sectionTitle)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(activeSession.map { "Connected to \($0.username)@\($0.hostname)" } ?? "Configure and connect to your servers")
                        .font(DSTypography.caption)
                        .foregroundStyle(activeSession == nil ? theme.colors.textSecondary : theme.colors.statusConnected)
                }
                
                Spacer(minLength: DSSpacing.sm)
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(theme.colors.textTertiary)
                    .accessibilityHidden(true)
            }
            .padding(DSSpacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .dsGlassSurface()
        }
        .buttonStyle(.plain)
        .accessibilityHint("Opens your saved hosts")
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
