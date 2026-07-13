import SwiftUI
import Domain
import DesignSystem
#if canImport(LocalAuthentication)
import LocalAuthentication
#endif

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
    @State private var isSessionDetailsUnlocked = false
    @State private var sessionUnlockError: String?

    let session: ConnectedHostSession
    let host: Domain.Host?
    let onDisconnect: () async -> Void
    
    private func content() -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.xl) {
                hostHeader
                workspaceActions
                sessionDetails
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
            Button("Cancel", role: .cancel) {}
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

            Button(role: .destructive) {
                isDisconnectConfirmationVisible = true
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(theme.colors.statusDisconnected)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Disconnect")
        }
    }

    private var sessionDetails: some View {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
            Text("Session")
                .font(DSTypography.sectionTitle)
                .foregroundStyle(theme.colors.textSecondary)
                .accessibilityAddTraits(.isHeader)

            Button {
                Task { await revealSessionDetails() }
            } label: {
                DSGlassSurface {
                    ZStack {
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
                        .blur(radius: isSessionDetailsUnlocked ? 0 : 6)
                        .opacity(isSessionDetailsUnlocked ? 1 : 0.46)

                        if !isSessionDetailsUnlocked {
                            Label("Reveal session details", systemImage: "lock.fill")
                                .font(.system(.footnote, weight: .semibold))
                                .foregroundStyle(theme.colors.textSecondary)
                                .padding(.horizontal, DSSpacing.md)
                                .padding(.vertical, DSSpacing.sm)
                                .background(theme.colors.surface.opacity(0.78), in: Capsule())
                        }
                    }
                }
            }
            .buttonStyle(.plain)
            .disabled(isSessionDetailsUnlocked)

            if let sessionUnlockError {
                Text(sessionUnlockError)
                    .font(DSTypography.caption)
                    .foregroundStyle(theme.colors.statusDisconnected)
            }
        }
    }

    private var workspaceActions: some View {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
            Text("Workspace")
                .font(.system(.title3, weight: .bold))
                .foregroundStyle(theme.colors.textPrimary)
                .accessibilityAddTraits(.isHeader)

            LazyVGrid(columns: workspaceColumns, spacing: DSSpacing.sm) {
                WorkspaceAction(title: "Terminal", icon: "terminal") {
                    router.push(.terminal(hostID: session.hostID.uuidString))
                }
                WorkspaceAction(title: "Files", icon: "folder") {
                    router.push(.files(hostID: session.hostID.uuidString, path: host?.primaryFavoriteRemotePath ?? "/"))
                }
                if host?.openClawConfiguration != nil {
                    WorkspaceAction(title: "OpenClaw", icon: "point.topleft.down.curvedto.point.bottomright.up", isPrimary: true) {
                        router.push(.openClawSession(id: session.hostID.uuidString))
                    }
                    WorkspaceAction(title: "Logs", icon: "bell.badge") {
                        router.push(.alerts)
                    }
                }
            }
        }
    }

    private var workspaceColumns: [GridItem] {
        [GridItem(.adaptive(minimum: 148), spacing: DSSpacing.sm, alignment: .top)]
    }

    private func revealSessionDetails() async {
        guard !isSessionDetailsUnlocked else { return }
        #if canImport(LocalAuthentication)
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            sessionUnlockError = "Device authentication is not available."
            return
        }
        do {
            let granted = try await context.evaluatePolicy(
                .deviceOwnerAuthentication,
                localizedReason: "Reveal SSH session details"
            )
            isSessionDetailsUnlocked = granted
            sessionUnlockError = granted ? nil : "Authentication was not completed."
        } catch {
            sessionUnlockError = "Authentication was cancelled."
        }
        #else
        isSessionDetailsUnlocked = true
        #endif
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
    var isPrimary = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(isPrimary ? theme.colors.textInverse : theme.colors.primary600)
                    .frame(width: 36, height: 36)
                    .background(isPrimary ? theme.colors.primary600 : theme.colors.primary100, in: RoundedRectangle(cornerRadius: DSRadius.sm, style: .continuous))
                Text(title)
                    .font(DSTypography.body.weight(.semibold))
                    .foregroundStyle(theme.colors.textPrimary)
            }
            .frame(maxWidth: .infinity, minHeight: 92, alignment: .leading)
            .padding(DSSpacing.md)
            .background(isPrimary ? theme.colors.primary600.opacity(0.12) : theme.colors.surface, in: RoundedRectangle(cornerRadius: DSRadius.sm, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: DSRadius.sm, style: .continuous)
                    .stroke(isPrimary ? theme.colors.primary600.opacity(0.5) : theme.colors.border, lineWidth: 1)
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
