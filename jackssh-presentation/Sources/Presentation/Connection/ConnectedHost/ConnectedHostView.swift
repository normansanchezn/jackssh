import SwiftUI
import Domain
import DesignSystem

public struct ConnectedHostView: View {
    let session: ConnectedHostSession
    let host: Domain.Host?
    let onDisconnect: () async -> Void

    public init(
        session: ConnectedHostSession,
        host: Domain.Host? = nil,
        onDisconnect: @escaping () async -> Void = {}
    ) {
        self.session = session
        self.host = host
        self.onDisconnect = onDisconnect
    }

    public var body: some View {
        _ConnectedHostContent(session: session, host: host, onDisconnect: onDisconnect)
    }
}

private struct _ConnectedHostContent: View {
    @Environment(AppRouter.self) private var router
    @Environment(\.jacksshTheme) private var theme
    @State private var isDisconnectConfirmationVisible = false

    let session: ConnectedHostSession
    let host: Domain.Host?
    let onDisconnect: () async -> Void
    
    private func content() -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.xl) {
                hostHeader
                sessionDetails
                workspaceActions
                disconnectControl
            }
            .padding(DSSpacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    var body: some View {
        DSBackground {
            content()
        }
        .navigationTitle(host?.name ?? session.hostname)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .confirmationDialog(
            "Disconnect from \(host?.name ?? session.hostname)?",
            isPresented: $isDisconnectConfirmationVisible,
            titleVisibility: .visible
        ) {
            Button("Disconnect", role: .destructive) {
                Task {
                    await onDisconnect()
                    router.popToRoot()
                }
            }
        } message: {
            Text("The active SSH session will be closed.")
        }
    }

    private var hostHeader: some View {
        HStack(alignment: .top, spacing: DSSpacing.md) {
            DSIconTile(symbol: "server.rack", tint: theme.colors.primary600, size: 52)

            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                Text(host?.name ?? session.hostname)
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundStyle(theme.colors.textPrimary)
                    .lineLimit(1)
                Text("\(session.username)@\(session.hostname)")
                    .font(DSTypography.mono)
                    .foregroundStyle(theme.colors.textSecondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
                DSStatusBadge(tone: .positive, label: "Connected")
                    .padding(.top, DSSpacing.xs)
            }
            Spacer(minLength: 0)
        }
    }

    private var sessionDetails: some View {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
            Text("Session")
                .font(DSTypography.sectionTitle)
                .accessibilityAddTraits(.isHeader)

            DSGlassSurface {
                VStack(spacing: 0) {
                    DSDetailRow(label: "User", value: session.username, symbol: "person")
                Divider().padding(.leading, 34)
                    DSDetailRow(label: "Host", value: "\(session.hostname):\(session.port)", symbol: "network")
                Divider().padding(.leading, 34)
                    DSDetailRow(
                        label: "Connected",
                        value: session.connectedAt.formatted(date: .abbreviated, time: .shortened),
                        symbol: "clock"
                    )
                }
                .padding(.horizontal, DSSpacing.lg)
                .padding(.vertical, DSSpacing.xs)
            }
        }
    }

    private var workspaceActions: some View {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
            Text("Workspace")
                .font(DSTypography.sectionTitle)
                .accessibilityAddTraits(.isHeader)

            PrimaryWorkspaceAction(title: "Terminal", subtitle: "Open an interactive shell", icon: "terminal") {
                router.push(.terminal(hostID: session.hostID.uuidString))
            }

            HStack(spacing: DSSpacing.sm) {
                WorkspaceAction(title: "Files", icon: "folder") {
                    router.push(.files(hostID: session.hostID.uuidString, path: host?.favoriteRemotePath ?? "/"))
                }
                if host?.openClawConfiguration != nil {
                    WorkspaceAction(title: "Dashboard", icon: "rectangle.3.group") {
                        router.push(.openClawSession(id: session.hostID.uuidString))
                    }
                }
            }
        }
    }

    private var disconnectControl: some View {
        Button(role: .destructive) {
            isDisconnectConfirmationVisible = true
        } label: {
            Label("Disconnect", systemImage: "xmark.circle")
                .font(DSTypography.body.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, DSSpacing.md)
        }
        .buttonStyle(.bordered)
    }
}

private struct PrimaryWorkspaceAction: View {
    @Environment(\.jacksshTheme) private var theme
    let title: String
    let subtitle: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: DSSpacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .frame(width: 42, height: 42)
                    .foregroundStyle(theme.colors.textInverse)
                    .background(theme.colors.primary600, in: RoundedRectangle(cornerRadius: DSRadius.sm, style: .continuous))
                VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                    Text(title)
                        .font(DSTypography.sectionTitle)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(subtitle)
                        .font(DSTypography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(theme.colors.primary600)
            }
            .padding(DSSpacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(theme.colors.surface, in: RoundedRectangle(cornerRadius: DSRadius.sm, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: DSRadius.sm, style: .continuous)
                    .stroke(theme.colors.primary300, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }
}

private struct WorkspaceAction: View {
    @Environment(\.jacksshTheme) private var theme
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(theme.colors.primary600)
                    .frame(width: 36, height: 36)
                    .background(theme.colors.primary100, in: RoundedRectangle(cornerRadius: DSRadius.sm, style: .continuous))
                Text(title)
                    .font(DSTypography.body.weight(.semibold))
                    .foregroundStyle(theme.colors.textPrimary)
            }
            .frame(maxWidth: .infinity, minHeight: 92, alignment: .leading)
            .padding(DSSpacing.md)
            .background(theme.colors.surface, in: RoundedRectangle(cornerRadius: DSRadius.sm, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: DSRadius.sm, style: .continuous)
                    .stroke(theme.colors.border, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview("Connected host") {
    let router = AppRouter()
    return NavigationStack {
        ConnectedHostView(
            session: ConnectedHostSession(
                hostID: PreviewFixtures.host.id,
                hostname: PreviewFixtures.host.hostname,
                username: PreviewFixtures.host.username,
                port: PreviewFixtures.host.port
            ),
            host: PreviewFixtures.host
        )
        .environment(router)
    }
    .withJacksshThemeAutomatic()
}
