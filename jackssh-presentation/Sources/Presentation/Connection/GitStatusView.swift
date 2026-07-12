import SwiftUI
import Domain
import DesignSystem

public struct GitStatusView: View {
    let hostID: String

    public init(hostID: String) {
        self.hostID = hostID
    }

    public var body: some View {
        VStack(spacing: DSSpacing.md) {
            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                Text("Git Status")
                    .font(DSTypography.sectionTitle)
                Text("Repository Status")
                    .font(DSTypography.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(DSSpacing.md)

            Divider()

            VStack(alignment: .leading, spacing: DSSpacing.lg) {
                DSCard {
                    VStack(alignment: .leading, spacing: DSSpacing.sm) {
                        HStack {
                            Text("Main Branch")
                                .font(DSTypography.body)
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        }
                        Text("Working tree clean")
                            .font(DSTypography.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                VStack(alignment: .leading, spacing: DSSpacing.sm) {
                    Text("Last Commit")
                        .font(DSTypography.caption)
                        .foregroundStyle(.secondary)
                    DSCard {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("abc1234")
                                .font(DSTypography.mono)
                                .foregroundStyle(.secondary)
                            Text("feat: add connection flow")
                                .font(DSTypography.body)
                        }
                    }
                }
            }
            .padding(DSSpacing.md)

            Spacer()
        }
        .navigationTitle("Git Status")
    }
}
