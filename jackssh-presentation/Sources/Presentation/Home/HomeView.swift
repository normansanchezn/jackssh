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
    private let dashboardTitle: String
    private let onLogout: () async -> Void
    private let onAddHost: () -> Void
    private let showsAccountMenu: Bool
    
    public init(
        viewModel: HomeViewModel,
        router: AppRouter,
        dashboardTitle: String = "Gest test",
        showsAccountMenu: Bool = true,
        onAddHost: @escaping () -> Void = {},
        onLogout: @escaping () async -> Void = {}
    ) {
        _viewModel = State(initialValue: viewModel)
        self.router = router
        self.dashboardTitle = dashboardTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Gest test" : dashboardTitle
        self.showsAccountMenu = showsAccountMenu
        self.onAddHost = onAddHost
        self.onLogout = onLogout
    }
    
    public var body: some View {
        DSBackground(showGrid: true) {
            ScrollView {
                VStack(alignment: .leading, spacing: DSSpacing.lg) {
                    Text(dashboardTitle)
                        .font(.system(.title, weight: .bold))
                        .foregroundStyle(theme.colors.textPrimary)
                        .padding(.top, horizontalSizeClass == .regular ? DSSpacing.xl : DSSpacing.lg)

                    switch viewModel.state {
                    case .idle, .loading:
                        loadingView
                    case .loaded:
                        loadedView()
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
            if shouldShowCompactAddHostButton {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        onAddHost()
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add host")
                }
            } else if showsAccountMenu {
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

    private var shouldShowCompactAddHostButton: Bool {
        horizontalSizeClass != .regular && viewModel.shouldOfferHostCreation
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
    
    private func loadedView() -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.xl) {
            hostCountCard
            openClawCard
            portForwardingCard
            statusRefreshedRow
        }
        .frame(maxWidth: horizontalSizeClass == .regular ? 860 : .infinity, alignment: .leading)
    }

    private var hostCountCard: some View {
        DSGlassSurface {
            HStack(alignment: .center, spacing: DSSpacing.lg) {
                DSIconTile(symbol: "server.rack", tint: theme.colors.primary600, size: 52)

                VStack(alignment: .leading, spacing: DSSpacing.xs) {
                    Text("\(viewModel.hostCount)")
                        .font(.system(.largeTitle, design: .monospaced, weight: .bold))
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(viewModel.hostCount == 1 ? "host agregado" : "hosts agregados")
                        .font(.system(.subheadline, weight: .semibold))
                        .foregroundStyle(theme.colors.textSecondary)
                }

                Spacer()
            }
            .padding(DSSpacing.lg)
        }
    }

    private var openClawCard: some View {
        Button {
            if let session = viewModel.activeSession {
                router.push(.openClawSession(id: session.hostID.uuidString))
            } else {
                router.push(.hosts)
            }
        } label: {
            HStack(alignment: .center, spacing: DSSpacing.lg) {
                OpenClawMark()

                VStack(alignment: .leading, spacing: DSSpacing.xs) {
                    Text("OpenClaw")
                        .font(.system(.title3, weight: .bold))
                        .foregroundStyle(theme.colors.textPrimary)
                    Text("Abre el dashboard a través del túnel SSH del host activo.")
                        .font(.system(.subheadline))
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(theme.colors.primary600)
            }
            .padding(DSSpacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .dsGlassSurface()
        }
        .buttonStyle(.plain)
        .accessibilityHint("Opens OpenClaw dashboard through port forwarding")
    }

    private var portForwardingCard: some View {
        Button {
            if let session = viewModel.activeSession {
                router.push(.openClawSession(id: session.hostID.uuidString))
            } else {
                router.push(.hosts)
            }
        } label: {
            DSGlassSurface(tint: theme.colors.primary600.opacity(0.12)) {
                VStack(alignment: .leading, spacing: DSSpacing.sm) {
                    HStack {
                        Label("Port Forwarding", systemImage: "point.topleft.down.curvedto.point.bottomright.up")
                            .font(.system(.headline, weight: .semibold))
                            .foregroundStyle(theme.colors.textPrimary)
                        Spacer()
                        Text(viewModel.activeSession == nil ? "Requiere host" : "Disponible")
                            .font(.system(size: 11, weight: .semibold, design: .monospaced))
                            .foregroundStyle(viewModel.activeSession == nil ? theme.colors.textSecondary : theme.colors.primary600)
                    }

                    Text("Crea el puente local iPad/iPhone → VPS para acceder a servicios remotos como OpenClaw.")
                        .font(.system(.subheadline))
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(DSSpacing.lg)
            }
        }
        .buttonStyle(.plain)
    }

    private var statusRefreshedRow: some View {
        HStack(spacing: DSSpacing.sm) {
            Image(systemName: "arrow.clockwise")
                .foregroundStyle(theme.colors.primary600)
            Text("Status refreshed")
                .font(.system(.footnote, weight: .semibold))
                .foregroundStyle(theme.colors.textSecondary)
            Spacer()
            Button("Refresh") {
                Task { await viewModel.load() }
            }
            .font(.system(.footnote, weight: .semibold))
        }
        .padding(.horizontal, DSSpacing.md)
        .padding(.vertical, DSSpacing.sm)
        .background(theme.colors.surface.opacity(0.66), in: Capsule())
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

private struct OpenClawMark: View {
    @Environment(\.jacksshTheme) private var theme

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: DSRadius.lg, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            theme.colors.primary600.opacity(0.95),
                            theme.colors.primary800.opacity(0.90)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Image(systemName: "pawprint.fill")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(theme.colors.textInverse)
        }
        .frame(width: 58, height: 58)
        .overlay {
            RoundedRectangle(cornerRadius: DSRadius.lg, style: .continuous)
                .stroke(theme.colors.primary700.opacity(0.55), lineWidth: 1)
        }
        .shadow(color: theme.colors.primary600.opacity(0.28), radius: 18, x: 0, y: 10)
        .accessibilityHidden(true)
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
