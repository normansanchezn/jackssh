import SwiftUI
import DesignSystem

struct AuthAdaptiveLayout<Content: View>: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.jacksshTheme) private var theme

    let title: String
    let subtitle: String
    let symbol: String
    let content: Content

    init(
        title: String,
        subtitle: String,
        symbol: String = "terminal.fill",
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.symbol = symbol
        self.content = content()
    }

    var body: some View {
        DSBackground(showGrid: true) {
            GeometryReader { proxy in
                if horizontalSizeClass == .regular, proxy.size.width >= 760 {
                    regularLayout
                } else {
                    compactLayout
                }
            }
        }
    }

    private var regularLayout: some View {
        HStack(spacing: 0) {
            sidePanel
                .frame(minWidth: 320, idealWidth: 390, maxWidth: 440)

            Divider()
                .opacity(0.45)

            ScrollView {
                formSurface
                    .padding(.horizontal, DSSpacing.xxl)
                    .padding(.vertical, 56)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var compactLayout: some View {
        ScrollView {
            VStack(spacing: DSSpacing.xl) {
                header
                content
            }
            .padding(DSSpacing.xl)
            .frame(maxWidth: 430)
            .frame(maxWidth: .infinity, minHeight: 620)
        }
    }

    private var formSurface: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xl) {
            header
                .frame(maxWidth: .infinity, alignment: .leading)
            content
        }
        .padding(.horizontal, DSSpacing.xxl)
        .padding(.vertical, DSSpacing.xxl)
        .frame(maxWidth: 460, alignment: .leading)
        .background(theme.colors.surface.opacity(0.82), in: RoundedRectangle(cornerRadius: DSRadius.md, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: DSRadius.md, style: .continuous)
                .stroke(theme.colors.border, lineWidth: 1)
        }
    }

    private var header: some View {
        VStack(alignment: horizontalSizeClass == .regular ? .leading : .center, spacing: DSSpacing.md) {
            Image("logo_jack_ssh", bundle: .module)
                
                .resizable()
                .frame(maxWidth: .infinity, alignment: .center)
                .aspectRatio(contentMode: .fit)

                .padding()

            VStack(alignment: horizontalSizeClass == .regular ? .leading : .center, spacing: DSSpacing.xs) {
                Text(title)
                    .font(
                        horizontalSizeClass == .regular ?
                            .system(
                                .title,
                                design: .rounded,
                                weight: .bold
                            )
                        : DSTypography.screenTitle
                    )
                    .foregroundStyle(theme.colors.textPrimary)
                    .multilineTextAlignment(
                        horizontalSizeClass == .regular ?
                            .leading : .center
                    )

                Text(subtitle)
                    .font(DSTypography.body)
                    .foregroundStyle(theme.colors.textSecondary)
                    .multilineTextAlignment(horizontalSizeClass == .regular ? .leading : .center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var sidePanel: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xxl) {
            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                Text("JackSSH")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .foregroundStyle(theme.colors.textPrimary)
                Text("Private OPS console")
                    .font(DSTypography.body)
                    .foregroundStyle(theme.colors.textSecondary)
            }

            VStack(alignment: .leading, spacing: DSSpacing.md) {
                AuthCapabilityRow(symbol: "lock.shield", title: "Secure session", value: "Supabase Auth")
                AuthCapabilityRow(symbol: "server.rack", title: "Hosts", value: "Local-first sync")
                AuthCapabilityRow(symbol: "terminal", title: "Workspace", value: "SSH, files, dashboards")
            }

            Spacer()

            Text("> ready")
                .font(.system(.body, design: .monospaced, weight: .semibold))
                .foregroundStyle(theme.colors.statusConnected)
        }
        .padding(44)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

private struct AuthCapabilityRow: View {
    @Environment(\.jacksshTheme) private var theme
    let symbol: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: DSSpacing.md) {
            Image(systemName: symbol)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(theme.colors.primary600)
                .frame(width: 34, height: 34)
                .background(theme.colors.surfaceElevated.opacity(0.82), in: RoundedRectangle(cornerRadius: DSRadius.sm, style: .continuous))

            VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                Text(title)
                    .font(DSTypography.caption.weight(.semibold))
                    .foregroundStyle(theme.colors.textPrimary)
                Text(value)
                    .font(DSTypography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
            }
        }
    }
}
