import SwiftUI
import DesignSystem

public struct TerminalView: View {
    let hostID: String

    public init(hostID: String) {
        self.hostID = hostID
    }

    public var body: some View {
        VStack(spacing: DSSpacing.md) {
            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                Text("Terminal")
                    .font(DSTypography.sectionTitle)
                Text("Interactive SSH shell")
                    .font(DSTypography.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(DSSpacing.md)

            Divider()

            VStack(alignment: .leading, spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: DSSpacing.xs) {
                        Text("$ ")
                            .font(DSTypography.mono)
                            .foregroundStyle(.green)
                    }
                    .padding(DSSpacing.md)
                }
                .background(Color.black)

                HStack(spacing: DSSpacing.sm) {
                    TextField("Command", text: .constant(""))
                        .font(DSTypography.mono)
                        .textFieldStyle(.roundedBorder)
                    Button {
                        // Send command
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                    }
                }
                .padding(DSSpacing.md)
            }

            Spacer()
        }
        .navigationTitle("Terminal")
    }
}
