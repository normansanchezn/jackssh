import SwiftUI
import Domain
import DesignSystem

public struct ConnectionStatusView: View {
    let status: ConnectionStatus

    public init(status: ConnectionStatus) {
        self.status = status
    }

    public var body: some View {
        HStack(spacing: DSSpacing.sm) {
            statusIcon
            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                Text(statusLabel)
                    .font(DSTypography.body)
                    .foregroundStyle(.primary)
                if let detail = statusDetail {
                    Text(detail)
                        .font(DSTypography.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
        }
        .padding(DSSpacing.md)
        .background(statusBackground)
        .cornerRadius(DSSpacing.sm)
    }

    @ViewBuilder
    private var statusIcon: some View {
        switch status.state {
        case .idle:
            Image(systemName: "circle")
                .foregroundStyle(.gray)
        case .connecting:
            ProgressView()
                .tint(.blue)
        case .connected:
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
        case .authenticationFailed:
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundStyle(.red)
        case .hostUnreachable:
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
        case .timeout:
            Image(systemName: "clock.badge.xmark")
                .foregroundStyle(.orange)
        case .hostKeyVerificationRequired:
            Image(systemName: "lock.open")
                .foregroundStyle(.yellow)
        case .hostKeyChanged:
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundStyle(.red)
        case .failed:
            Image(systemName: "xmark.circle.fill")
                .foregroundStyle(.red)
        }
    }

    private var statusLabel: String {
        switch status.state {
        case .idle:
            return "Not connected"
        case .connecting:
            return "Connecting…"
        case .connected:
            return "Connected"
        case .authenticationFailed:
            return "Authentication Failed"
        case .hostUnreachable:
            return "Host Unreachable"
        case .timeout:
            return "Connection Timeout"
        case .hostKeyVerificationRequired:
            return "Verify Host Key"
        case .hostKeyChanged:
            return "Host Key Changed"
        case .failed:
            return "Connection Error"
        }
    }

    private var statusDetail: String? {
        switch status.state {
        case .authenticationFailed(let msg):
            return msg
        case .hostUnreachable(let msg):
            return msg
        case .hostKeyVerificationRequired(let key):
            return "Fingerprint: \(key)"
        case .hostKeyChanged(let msg):
            return msg
        case .failed(let msg):
            return msg
        default:
            return nil
        }
    }

    private var statusBackground: Color {
        switch status.state {
        case .connected:
            return Color.green.opacity(0.1)
        case .authenticationFailed, .hostKeyChanged, .failed:
            return Color.red.opacity(0.1)
        case .hostUnreachable, .timeout:
            return Color.orange.opacity(0.1)
        case .hostKeyVerificationRequired:
            return Color.yellow.opacity(0.1)
        default:
            return Color.gray.opacity(0.05)
        }
    }
}
