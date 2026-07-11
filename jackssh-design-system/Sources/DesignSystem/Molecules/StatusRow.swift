import SwiftUI

/// Molecule: a labelled row with a leading SF Symbol and a trailing status badge.
/// Used for the Home status list. Combines into one accessibility element.
public struct StatusRow: View {
    private let systemImage: String
    private let title: String
    private let tone: StatusTone
    private let statusLabel: String

    public init(systemImage: String, title: String, tone: StatusTone, statusLabel: String) {
        self.systemImage = systemImage
        self.title = title
        self.tone = tone
        self.statusLabel = statusLabel
    }

    public var body: some View {
        HStack(spacing: DSSpacing.md) {
            Image(systemName: systemImage)
                .foregroundStyle(.secondary)
                .frame(width: 24)
                .accessibilityHidden(true)
            Text(title)
                .font(DSTypography.body)
            Spacer(minLength: DSSpacing.sm)
            StatusBadge(tone: tone, label: statusLabel)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(statusLabel)")
    }
}
