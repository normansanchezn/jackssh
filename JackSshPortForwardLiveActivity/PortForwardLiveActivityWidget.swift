import ActivityKit
import Shared
import SwiftUI
import WidgetKit

struct PortForwardLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PortForwardActivityAttributes.self) { context in
            PortForwardLockScreenView(context: context)
                .activityBackgroundTint(Color(red: 0.02, green: 0.03, blue: 0.06))
                .activitySystemActionForegroundColor(.white)
                .widgetURL(Self.dashboardURL(for: context))
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    PortForwardStatusLabel(status: context.state.status)
                }

                DynamicIslandExpandedRegion(.trailing) {
                    Text(":\(context.state.localPort)")
                        .font(.system(.headline, design: .monospaced))
                        .foregroundStyle(.white)
                }

                DynamicIslandExpandedRegion(.bottom) {
                    HStack(alignment: .bottom, spacing: 10) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(context.state.hostName)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.white)
                            Text(context.state.tunnelDescription)
                                .font(.caption2.monospaced())
                                .foregroundStyle(.white.opacity(0.72))
                                .lineLimit(1)
                        }
                        Spacer(minLength: 0)
                        Link(destination: Self.dashboardURL(for: context)!) {
                            Label("Stop", systemImage: "xmark.circle.fill")
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(.red.opacity(0.72), in: Capsule())
                        }
                    }
                }
            } compactLeading: {
                Image(systemName: "point.topleft.down.curvedto.point.bottomright.up.fill")
                    .foregroundStyle(.cyan)
            } compactTrailing: {
                Text("\(context.state.localPort)")
                    .font(.caption2.monospacedDigit().weight(.semibold))
                    .foregroundStyle(.white)
            } minimal: {
                Image(systemName: "bolt.horizontal.circle.fill")
                    .foregroundStyle(.cyan)
            }
            .widgetURL(Self.dashboardURL(for: context))
        }
    }

    private static func dashboardURL(for context: ActivityViewContext<PortForwardActivityAttributes>) -> URL? {
        URL(string: "jackssh://openclaw/session/\(context.attributes.hostID)")
    }
}

private struct PortForwardLockScreenView: View {
    let context: ActivityViewContext<PortForwardActivityAttributes>

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(red: 0.31, green: 0.67, blue: 0.98).opacity(0.18))
                Image(systemName: "point.topleft.down.curvedto.point.bottomright.up.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color(red: 0.31, green: 0.67, blue: 0.98))
            }
            .frame(width: 42, height: 42)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(context.state.status)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                    Text("OpenClaw")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(Color(red: 0.31, green: 0.67, blue: 0.98))
                }

                Text(context.state.hostName)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(0.82))

                Text(context.state.tunnelDescription)
                    .font(.caption2.monospaced())
                    .foregroundStyle(.white.opacity(0.62))
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 6) {
                Text(":\(context.state.localPort)")
                    .font(.system(.callout, design: .monospaced).weight(.semibold))
                    .foregroundStyle(.white)
                Link(destination: dashboardURL) {
                    Text("Stop")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(.red.opacity(0.72), in: Capsule())
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
    }

    private var dashboardURL: URL {
        URL(string: "jackssh://openclaw/session/\(context.attributes.hostID)")!
    }
}

private struct PortForwardStatusLabel: View {
    let status: String

    var body: some View {
        Label(status, systemImage: "bolt.horizontal.circle.fill")
            .font(.caption.weight(.semibold))
            .foregroundStyle(Color(red: 0.31, green: 0.67, blue: 0.98))
    }
}
