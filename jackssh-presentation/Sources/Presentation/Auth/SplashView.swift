import SwiftUI
import DesignSystem

public struct SplashView: View {
    public init() {}

    public var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            VStack(spacing: DSSpacing.lg) {
                Spacer()

                VStack(spacing: DSSpacing.md) {
                    Image(systemName: "terminal.fill")
                        .font(.system(size: 72))
                        .foregroundStyle(.blue)

                    Text("JackSsh")
                        .font(DSTypography.screenTitle)
                        .foregroundStyle(.primary)

                    Text("SSH Terminal & VPS Management")
                        .font(DSTypography.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                ProgressView()
                    .tint(.blue)
                    .scaleEffect(1.5, anchor: .center)

                Text("Loading...")
                    .font(DSTypography.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(DSSpacing.lg)
        }
    }
}
