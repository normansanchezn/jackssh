import ActivityKit
import Shared
import SwiftUI
import WidgetKit

struct PortForwardLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PortForwardActivityAttributes.self) { context in
            PortForwardLockScreenView(context: context)
                .activityBackgroundTint(PortForwardStyle.background)
                .activitySystemActionForegroundColor(.white)
                .widgetURL(Self.dashboardURL(for: context))
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 3) {
                        PortForwardStatusLabel(status: context.state.status)
                        Text(context.state.hostName)
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(PortForwardStyle.secondaryText)
                            .lineLimit(1)
                    }
                }

                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 3) {
                        Text(":\(context.state.localPort)")
                            .font(.system(.headline, design: .monospaced).weight(.semibold))
                            .foregroundStyle(.white)
                        Text(context.state.startedAt, style: .timer)
                            .font(.caption2.monospacedDigit())
                            .foregroundStyle(PortForwardStyle.secondaryText)
                    }
                }

                DynamicIslandExpandedRegion(.bottom) {
                    PortForwardExpandedIslandView(context: context)
                }
            } compactLeading: {
                Image(systemName: "point.topleft.down.curvedto.point.bottomright.up.fill")
                    .foregroundStyle(PortForwardStyle.accent)
            } compactTrailing: {
                Text(":\(context.state.localPort)")
                    .font(.caption2.monospacedDigit().weight(.semibold))
                    .foregroundStyle(.white)
            } minimal: {
                Image(systemName: "bolt.horizontal.circle.fill")
                    .foregroundStyle(PortForwardStyle.accent)
            }
            .widgetURL(Self.dashboardURL(for: context))
        }
    }

    private static func dashboardURL(for context: ActivityViewContext<PortForwardActivityAttributes>) -> URL? {
        URL(string: "jackssh://openclaw/session/\(context.attributes.hostID)")
    }

    private static func stopURL(for context: ActivityViewContext<PortForwardActivityAttributes>) -> URL? {
        URL(string: "jackssh://openclaw/stop/\(context.attributes.hostID)")
    }
}

private struct PortForwardLockScreenView: View {
    let context: ActivityViewContext<PortForwardActivityAttributes>

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            PortForwardGlyph(size: 44)

            VStack(alignment: .leading, spacing: 7) {
                HStack(spacing: 7) {
                    Text("OpenClaw bridge")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                    PortForwardStatePill(status: context.state.status)
                }

                Text(context.state.hostName)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(PortForwardStyle.secondaryText)
                    .lineLimit(1)

                Text(context.state.tunnelDescription)
                    .font(.caption2.monospaced())
                    .foregroundStyle(PortForwardStyle.tertiaryText)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 8) {
                Text(":\(context.state.localPort)")
                    .font(.system(.callout, design: .monospaced).weight(.bold))
                    .foregroundStyle(.white)
                Text(context.state.startedAt, style: .timer)
                    .font(.caption2.monospacedDigit().weight(.medium))
                    .foregroundStyle(PortForwardStyle.secondaryText)
                StopForwardingLink(url: stopURL)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 6)
    }

    private var dashboardURL: URL {
        URL(string: "jackssh://openclaw/session/\(context.attributes.hostID)")!
    }

    private var stopURL: URL {
        URL(string: "jackssh://openclaw/stop/\(context.attributes.hostID)")!
    }
}

private struct PortForwardStatusLabel: View {
    let status: String

    var body: some View {
        Label(status, systemImage: "link")
            .font(.caption.weight(.semibold))
            .foregroundStyle(PortForwardStyle.accent)
    }
}

private struct PortForwardExpandedIslandView: View {
    let context: ActivityViewContext<PortForwardActivityAttributes>

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                Text(context.state.tunnelDescription)
                    .font(.caption2.monospaced())
                    .foregroundStyle(PortForwardStyle.secondaryText)
                    .lineLimit(1)
                HStack(spacing: 8) {
                    Text("Local :\(context.state.localPort)")
                        .font(.caption2.monospacedDigit().weight(.semibold))
                        .foregroundStyle(.white)
                    Text(context.state.startedAt, style: .timer)
                        .font(.caption2.monospacedDigit())
                        .foregroundStyle(PortForwardStyle.tertiaryText)
                }
            }
            Spacer(minLength: 0)
            if let url = URL(string: "jackssh://openclaw/stop/\(context.attributes.hostID)") {
                StopForwardingLink(url: url)
            }
        }
    }
}

private struct StopForwardingLink: View {
    let url: URL

    var body: some View {
        Link(destination: url) {
            Label("Stop", systemImage: "xmark")
                .font(.caption2.weight(.bold))
                .foregroundStyle(.white)
                .labelStyle(.titleAndIcon)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(PortForwardStyle.danger, in: Capsule())
        }
    }
}

private struct PortForwardStatePill: View {
    let status: String

    var body: some View {
        Text(status)
            .font(.caption2.weight(.bold))
            .foregroundStyle(PortForwardStyle.accent)
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(PortForwardStyle.accent.opacity(0.14), in: Capsule())
    }
}

private struct PortForwardGlyph: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .fill(PortForwardStyle.accent.opacity(0.14))
            Image(systemName: "point.topleft.down.curvedto.point.bottomright.up.fill")
                .font(.system(size: size * 0.42, weight: .semibold))
                .foregroundStyle(PortForwardStyle.accent)
        }
        .frame(width: size, height: size)
        .overlay {
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .stroke(PortForwardStyle.accent.opacity(0.30), lineWidth: 1)
        }
    }
}

private enum PortForwardStyle {
    static let background = Color(red: 0.025, green: 0.035, blue: 0.055)
    static let accent = Color(red: 0x4E / 255, green: 0xAC / 255, blue: 0xF9 / 255)
    static let danger = Color(red: 0.92, green: 0.18, blue: 0.24)
    static let secondaryText = Color.white.opacity(0.78)
    static let tertiaryText = Color.white.opacity(0.56)
}
