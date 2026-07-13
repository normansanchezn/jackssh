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
        .refreshable {
            await viewModel.load()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text("OpenClaw")
                .font(DSTypography.caption.weight(.semibold))
                .foregroundStyle(theme.colors.textSecondary)
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
                    Text("Checking OpenClaw logs")
                        .font(DSTypography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                }
                .padding(DSSpacing.lg)
            }
        case .loaded:
            if let error = viewModel.openClawLogsError {
                ContentUnavailableView("OpenClaw logs unavailable", systemImage: "bell.slash", description: Text(error))
            } else if viewModel.openClawLogs.isEmpty {
                ContentUnavailableView(
                    "No OpenClaw alerts",
                    systemImage: "checkmark.circle",
                    description: Text("Only warning and error logs are shown here.")
                )
            } else {
                alertsList(viewModel.openClawLogs)
            }
        case let .failed(error):
            ContentUnavailableView("Alerts unavailable", systemImage: "bell.slash", description: Text(error.localizedDescription))
        }
    }

    private func alertsList(_ logs: [OpenClawLogEntry]) -> some View {
        DSGlassSurface {
            VStack(spacing: 0) {
                ForEach(Array(logs.enumerated()), id: \.element.id) { index, log in
                    AlertRow(log: log)
                    if index < logs.count - 1 {
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
}

private struct AlertRow: View {
    @Environment(\.jacksshTheme) private var theme
    let log: OpenClawLogEntry

    var body: some View {
        HStack(alignment: .top, spacing: DSSpacing.sm) {
            Circle()
                .fill(toneColor)
                .frame(width: 6, height: 6)
                .padding(.top, 7)

            VStack(alignment: .leading, spacing: 3) {
                HStack(alignment: .firstTextBaseline, spacing: DSSpacing.sm) {
                    Text(log.severity == .error ? "Error" : "Warning")
                        .font(DSTypography.caption.weight(.semibold))
                        .foregroundStyle(theme.colors.textPrimary)
                        .lineLimit(1)
                    if let source = log.source {
                        Text(source.uppercased())
                            .font(.system(size: 8, weight: .bold))
                            .foregroundStyle(theme.colors.textTertiary)
                            .lineLimit(1)
                    }
                    Spacer(minLength: DSSpacing.sm)
                    Text(log.timestamp, style: .relative)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(theme.colors.textTertiary)
                        .lineLimit(1)
                }
                Text(log.message)
                    .font(.system(size: 10))
                    .foregroundStyle(theme.colors.textSecondary)
                    .lineLimit(3)
            }
        }
        .padding(.vertical, DSSpacing.sm)
    }

    private var toneColor: Color {
        log.severity == .error ? theme.colors.statusDisconnected : theme.colors.statusPending
    }
}
