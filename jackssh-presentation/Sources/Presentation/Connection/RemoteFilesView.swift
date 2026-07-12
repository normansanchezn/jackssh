import SwiftUI
import DesignSystem

public struct RemoteFilesView: View {
    let hostID: String
    let path: String

    public init(hostID: String, path: String) {
        self.hostID = hostID
        self.path = path
    }

    public var body: some View {
        VStack(spacing: DSSpacing.md) {
            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                Text("Files")
                    .font(DSTypography.sectionTitle)
                Text(path)
                    .font(DSTypography.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .padding(DSSpacing.md)

            Divider()

            VStack(alignment: .leading, spacing: DSSpacing.md) {
                DSCard {
                    HStack {
                        Image(systemName: "folder")
                            .font(.title3)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("projects")
                                .font(DSTypography.body)
                            Text("Folder")
                                .font(DSTypography.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                }

                DSCard {
                    HStack {
                        Image(systemName: "doc.text")
                            .font(.title3)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("README.md")
                                .font(DSTypography.body)
                            Text("4.2 KB")
                                .font(DSTypography.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                }
            }
            .padding(DSSpacing.md)

            Spacer()
        }
        .navigationTitle("Files")
    }
}
