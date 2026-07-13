import SwiftUI

public struct DSMetricTile: View {
    @Environment(\.jacksshTheme) private var theme
    private let value: String
    private let label: String
    private let caption: String
    private let tone: StatusTone

    public init(value: String, label: String, caption: String, tone: StatusTone) {
        self.value = value
        self.label = label
        self.caption = caption
        self.tone = tone
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text(value)
                .font(.system(.title3, design: .monospaced, weight: .semibold))
                .foregroundStyle(toneColor)
                .lineLimit(1)
            Text(label)
                .font(DSTypography.caption.weight(.semibold))
                .foregroundStyle(theme.colors.textPrimary)
                .lineLimit(1)
            Text(caption)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(theme.colors.textTertiary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, DSSpacing.md)
        .padding(.vertical, DSSpacing.sm)
        .background(toneColor.opacity(0.12), in: RoundedRectangle(cornerRadius: DSRadius.sm, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: DSRadius.sm, style: .continuous)
                .stroke(toneColor.opacity(0.45), lineWidth: 1)
        }
    }

    private var toneColor: Color {
        switch tone {
        case .positive: return theme.colors.statusConnected
        case .warning: return theme.colors.statusPending
        case .critical: return theme.colors.statusDisconnected
        case .neutral: return theme.colors.textTertiary
        }
    }
}

public struct DSOpsStatusRow: View {
    @Environment(\.jacksshTheme) private var theme
    private let systemImage: String
    private let title: String
    private let subtitle: String?
    private let tone: StatusTone
    private let statusLabel: String

    public init(
        systemImage: String,
        title: String,
        subtitle: String? = nil,
        tone: StatusTone,
        statusLabel: String
    ) {
        self.systemImage = systemImage
        self.title = title
        self.subtitle = subtitle
        self.tone = tone
        self.statusLabel = statusLabel
    }

    public var body: some View {
        HStack(spacing: DSSpacing.sm) {
            Image(systemName: systemImage)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(toneColor)
                .frame(width: 24, height: 24)
                .background(toneColor.opacity(0.13), in: RoundedRectangle(cornerRadius: DSRadius.xs, style: .continuous))

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(DSTypography.caption.weight(.semibold))
                    .foregroundStyle(theme.colors.textPrimary)
                    .lineLimit(1)
                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundStyle(theme.colors.textTertiary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
            }

            Spacer(minLength: DSSpacing.sm)

            HStack(spacing: DSSpacing.xs) {
                Circle()
                    .fill(toneColor)
                    .frame(width: 5, height: 5)
                Text(statusLabel)
                    .font(.system(size: 9, weight: .semibold, design: .monospaced))
                    .foregroundStyle(toneColor)
                    .lineLimit(1)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(statusLabel)")
    }

    private var toneColor: Color {
        switch tone {
        case .positive: return theme.colors.statusConnected
        case .warning: return theme.colors.statusPending
        case .critical: return theme.colors.statusDisconnected
        case .neutral: return theme.colors.textTertiary
        }
    }
}

public struct DSBottomNavItem: Identifiable, Sendable {
    public let id: String
    public let title: String
    public let systemImage: String
    public let badgeCount: Int
    public let isEnabled: Bool
    public let action: @MainActor () -> Void

    public init(
        id: String,
        title: String,
        systemImage: String,
        badgeCount: Int = 0,
        isEnabled: Bool = true,
        action: @escaping @MainActor () -> Void
    ) {
        self.id = id
        self.title = title
        self.systemImage = systemImage
        self.badgeCount = badgeCount
        self.isEnabled = isEnabled
        self.action = action
    }
}

public struct DSFloatingBottomNav: View {
    @Environment(\.jacksshTheme) private var theme
    private let selectedID: String
    private let items: [DSBottomNavItem]

    public init(selectedID: String, items: [DSBottomNavItem]) {
        self.selectedID = selectedID
        self.items = items
    }

    public var body: some View {
        HStack(spacing: DSSpacing.xs) {
            ForEach(items) { item in
                Button {
                    item.action()
                } label: {
                    VStack(spacing: 2) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: item.systemImage)
                                .font(.system(size: 14, weight: .semibold))
                                .frame(width: 36, height: 28)
                            if item.badgeCount > 0 {
                                Text("\(item.badgeCount)")
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundStyle(theme.colors.textPrimary)
                                    .frame(width: 14, height: 14)
                                    .background(theme.colors.statusDisconnected, in: Circle())
                                    .offset(x: 3, y: -2)
                            }
                        }
                        Text(item.title)
                            .font(.system(size: 8, weight: .semibold))
                            .lineLimit(1)
                    }
                    .foregroundStyle(item.id == selectedID ? theme.colors.primary600 : theme.colors.textTertiary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DSSpacing.xs)
                    .background {
                        if item.id == selectedID {
                            RoundedRectangle(cornerRadius: DSRadius.sm, style: .continuous)
                                .fill(theme.colors.primary600.opacity(0.14))
                                .overlay {
                                    RoundedRectangle(cornerRadius: DSRadius.sm, style: .continuous)
                                        .stroke(theme.colors.primary600.opacity(0.38), lineWidth: 1)
                                }
                        }
                    }
                }
                .buttonStyle(.plain)
                .disabled(!item.isEnabled)
                .opacity(item.isEnabled ? 1 : 0.36)
                .accessibilityLabel(item.title)
            }
        }
        .padding(.horizontal, DSSpacing.sm)
        .padding(.vertical, DSSpacing.xs)
        .background(theme.colors.surface.opacity(0.86), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(theme.colors.border.opacity(0.85), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.36), radius: 18, x: 0, y: 10)
    }
}
