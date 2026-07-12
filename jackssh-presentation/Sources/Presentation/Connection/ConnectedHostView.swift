import SwiftUI
import Domain
import DesignSystem

public struct ConnectedHostView: View {
    let session: ConnectedHostSession
    let host: Domain.Host?
    @Environment(AppRouter.self) private var router

    public init(session: ConnectedHostSession, host: Domain.Host? = nil) {
        self.session = session
        self.host = host
    }

    public var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            VStack(spacing: DSSpacing.lg) {
                VStack(alignment: .leading, spacing: DSSpacing.sm) {
                    Text(host?.name ?? session.hostname)
                        .font(DSTypography.sectionTitle)
                    HStack(spacing: DSSpacing.sm) {
                        Image(systemName: "circle.fill")
                            .foregroundStyle(.green)
                            .font(.caption)
                        Text("Connected")
                            .font(DSTypography.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(DSSpacing.md)

                DSCard {
                    VStack(alignment: .leading, spacing: DSSpacing.md) {
                        row(label: "User", value: session.username)
                        row(label: "Host", value: "\(session.hostname):\(session.port)")
                        row(label: "Connected at", value: session.connectedAt.formatted(date: .abbreviated, time: .shortened))
                    }
                }

                VStack(spacing: DSSpacing.sm) {
                    Text("Quick Actions")
                        .font(DSTypography.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    QuickActionButton(label: "Open Dashboard", systemImage: "globe") {
                        router.push(.terminal(hostID: session.hostID.uuidString))
                    }
                    QuickActionButton(label: "Terminal", systemImage: "terminal") {
                        router.push(.terminal(hostID: session.hostID.uuidString))
                    }
                    QuickActionButton(label: "Browse Files", systemImage: "folder") {
                        router.push(.files(hostID: session.hostID.uuidString, path: "/"))
                    }
                    QuickActionButton(label: "Git Status", systemImage: "git") {
                        router.push(.terminal(hostID: session.hostID.uuidString))
                    }
                }
                .padding(DSSpacing.md)

                Spacer()

                Button(role: .destructive) {
                    router.popToRoot()
                } label: {
                    Text("Disconnect")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .padding(DSSpacing.md)
            }
            .padding(DSSpacing.lg)
        }
    }

    private func row(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(DSTypography.caption)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(DSTypography.mono)
                .foregroundStyle(.primary)
        }
    }
}

private struct QuickActionButton: View {
    let label: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: DSSpacing.sm) {
                Image(systemName: systemImage)
                    .frame(width: 24)
                Text(label)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(DSSpacing.md)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}
