import SwiftUI
import Domain
import DesignSystem

/// Declarative Home screen. All logic lives in `HomeViewModel`; this view only
/// renders state and forwards navigation intents to the router.
public struct HomeView: View {
    @State private var viewModel: HomeViewModel
    private let router: AppRouter

    public init(viewModel: HomeViewModel, router: AppRouter) {
        _viewModel = State(initialValue: viewModel)
        self.router = router
    }

    public var body: some View {
        ScreenScaffold(title: "JackSsh") {
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
            DSCard {
                VStack(alignment: .leading, spacing: DSSpacing.md) {
                    Text("Status")
                        .font(DSTypography.sectionTitle)
                    StatusRow(
                        systemImage: "network",
                        title: "Private network",
                        tone: status.privateNetworkOnline ? .positive : .critical,
                        statusLabel: status.privateNetworkOnline ? "Connected" : "Down"
                    )
                    StatusRow(systemImage: "server.rack", title: "VPS",
                              tone: status.vps.tone, statusLabel: status.vps.label)
                    StatusRow(systemImage: "sparkles", title: "OpenClaw",
                              tone: status.openClaw.tone, statusLabel: status.openClaw.label)
                    StatusRow(systemImage: "cpu", title: "Ollama",
                              tone: status.ollama.tone, statusLabel: status.ollama.label)
                }
            }
            recentActivity(status.recentActivity)
        }
    }

    private func recentActivity(_ events: [ActivityEvent]) -> some View {
        DSCard {
            VStack(alignment: .leading, spacing: DSSpacing.md) {
                Text("Recent activity")
                    .font(DSTypography.sectionTitle)
                if events.isEmpty {
                    Text("No recent activity")
                        .font(DSTypography.body)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(events) { event in
                        StatusRow(
                            systemImage: "clock",
                            title: event.title,
                            tone: event.state.tone,
                            statusLabel: event.state.label
                        )
                    }
                }
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
