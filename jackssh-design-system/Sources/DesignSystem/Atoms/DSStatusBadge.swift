import SwiftUI

/// Atom: a compact status pill — tone-colored SF Symbol plus label.
/// VoiceOver reads a single combined label; the symbol is decorative.
///
/// Overview: The DSStatusBadge struct creates a small, compact status indicator that combines an SF Symbol with a textual label. The badge has a tone-based color which automatically adjusts to light and dark mode.
///
/// Parameters:
///   - tone: The tone of the badge, dictating its color.
///     - Values: `.success`, `.error`, `.warning`, etc.
///   - label: The text label displayed with the badge's symbol.
public struct DSStatusBadge: View {
    private let tone: StatusTone
    private let label: String

    public init(tone: StatusTone, label: String) {
        self.tone = tone
        self.label = label
    }

    public var body: some View {
        HStack(spacing: DSSpacing.xs) {
            Image(systemName: tone.symbolName)
                .imageScale(.small)
            Text(label)
                .font(DSTypography.caption)
        }
        .foregroundStyle(tone.color)
        .padding(.horizontal, DSSpacing.sm)
        .padding(.vertical, DSSpacing.xxs)
        .background(tone.color.opacity(0.12), in: Capsule())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label), \(tone.rawValue)")
    }
}

#Preview {
    VStack(alignment: .leading, spacing: DSSpacing.sm) {
        ForEach(StatusTone.allCases, id: \.self) { tone in
            DSStatusBadge(tone: tone, label: tone.rawValue.capitalized)
        }
    }
    .padding()
}
