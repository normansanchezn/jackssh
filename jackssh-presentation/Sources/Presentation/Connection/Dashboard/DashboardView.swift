import SwiftUI
import DesignSystem

public struct DashboardView: View {
    let hostID: String

    public init(hostID: String) {
        self.hostID = hostID
    }

    public var body: some View {
        VStack(spacing: DSSpacing.md) {
            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                Text("Dashboard")
                    .font(DSTypography.sectionTitle)
                Text("OpenClaw Management")
                    .font(DSTypography.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(DSSpacing.md)

            Divider()

            VStack(alignment: .center, spacing: DSSpacing.lg) {
                Image(systemName: "globe")
                    .font(.system(size: 64))
                    .foregroundStyle(.blue)

                Text("Dashboard Loading")
                    .font(DSTypography.sectionTitle)

                Text("WebView will display OpenClaw dashboard here")
                    .font(DSTypography.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(DSSpacing.lg)

            Spacer()
        }
        .navigationTitle("Dashboard")
    }
}
