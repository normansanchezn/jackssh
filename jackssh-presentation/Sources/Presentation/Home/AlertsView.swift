import SwiftUI
import Domain
import DesignSystem

public struct AlertsView: View {
    @State private var viewModel: HomeViewModel
    @Environment(\.jacksshTheme) private var theme

    public init(viewModel: HomeViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        DSBackground(showGrid: true) {
            ScrollView {
                VStack(alignment: .leading, spacing: DSSpacing.lg) {
                    header
                    alertsContent
                }
                .padding(.horizontal, DSSpacing.lg)
                .padding(.top, DSSpacing.md)
                .padding(.bottom, 96)
            }
        }
        .navigationTitle("Alerts")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .task { await viewModel.load() }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text("Clear all")
                .font(DSTypography.caption.weight(.semibold))
                .foregroundStyle(theme.colors.primary600)
            Text("Alerts")
                .font(.system(.title2, weight: .bold))
                .foregroundStyle(theme.colors.textPrimary)
        }
    }

    @ViewBuilder
    private var alertsContent: some View {
        switch viewModel.state {
        case .idle, .loading:
            DSGlassSurface {
                HStack(spacing: DSSpacing.md) {
                    ProgressView()
                    Text("Checking alerts")
                        .font(DSTypography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                }
                .padding(DSSpacing.lg)
            }
        case let .loaded(status):
            alertsList(events(from: status))
        case let .failed(error):
            ContentUnavailableView("Alerts unavailable", systemImage: "bell.slash", description: Text(error.localizedDescription))
        }
    }

    private func alertsList(_ events: [ActivityEvent]) -> some View {
        DSGlassSurface {
            VStack(spacing: 0) {
                ForEach(Array(events.enumerated()), id: \.element.id) { index, event in
                    AlertRow(event: event)
                    if index < events.count - 1 {
                        Divider()
                            .overlay(theme.colors.border.opacity(0.55))
                            .padding(.leading, 20)
                    }
                }
            }
            .padding(.horizontal, DSSpacing.md)
            .padding(.vertical, DSSpacing.sm)
        }
    }

    private func events(from status: HomeStatus) -> [ActivityEvent] {
        if !status.recentActivity.isEmpty {
            return status.recentActivity
        }
        return [
            ActivityEvent(title: "OpenClaw dashboard ready", timestamp: Date(), state: status.openClaw),
            ActivityEvent(title: "Private network \(status.privateNetworkOnline ? "online" : "down")", timestamp: Date().addingTimeInterval(-900), state: status.privateNetworkOnline ? .online : .offline),
            ActivityEvent(title: "VPS \(status.vps.label.lowercased())", timestamp: Date().addingTimeInterval(-1_800), state: status.vps),
        ]
    }
}

private struct AlertRow: View {
    @Environment(\.jacksshTheme) private var theme
    let event: ActivityEvent

    var body: some View {
        HStack(alignment: .top, spacing: DSSpacing.sm) {
            Circle()
                .fill(toneColor)
                .frame(width: 6, height: 6)
                .padding(.top, 7)

            VStack(alignment: .leading, spacing: 3) {
                HStack(alignment: .firstTextBaseline, spacing: DSSpacing.sm) {
                    Text(event.title)
                        .font(DSTypography.caption.weight(.semibold))
                        .foregroundStyle(theme.colors.textPrimary)
                        .lineLimit(1)
                    Spacer(minLength: DSSpacing.sm)
                    Text(event.timestamp, style: .relative)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(theme.colors.textTertiary)
                        .lineLimit(1)
                }
                Text(detail)
                    .font(.system(size: 10))
                    .foregroundStyle(theme.colors.textSecondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, DSSpacing.sm)
    }

    private var detail: String {
        switch event.state {
        case .online: return "Service is reachable through the configured route."
        case .degraded: return "Service responded, but needs attention."
        case .offline: return "Service is not reachable from this device."
        case .unknown: return "No recent signal has been recorded."
        }
    }

    private var toneColor: Color {
        switch event.state.tone {
        case .positive: return theme.colors.statusConnected
        case .warning: return theme.colors.statusPending
        case .critical: return theme.colors.statusDisconnected
        case .neutral: return theme.colors.textTertiary
        }
    }
}
