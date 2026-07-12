import SwiftUI
import DesignSystem
import Domain

public struct TerminalView: View {
    let hostID: String
    let dependencies: HostsDependencies

    public init(hostID: String, dependencies: HostsDependencies) {
        self.hostID = hostID
        self.dependencies = dependencies
    }

    public var body: some View {
        if let uuid = UUID(uuidString: hostID) {
            TerminalScreen(viewModel: dependencies.makeTerminalViewModel(uuid))
        } else {
            Text("Invalid host ID")
        }
    }
}

struct TerminalScreen: View {
    @State private var viewModel: TerminalViewModel

    init(viewModel: TerminalViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ZStack {
            Color(red: 0x1B/255, green: 0x1D/255, blue: 0x21/255).ignoresSafeArea()

            if let session = viewModel.session {
                VStack(spacing: 0) {
                    TerminalStatusBar(
                        title: viewModel.connectionTitle,
                        phase: session.phase,
                        onReconnect: { session.reconnectNow() }
                    )
                    #if os(iOS)
                    TerminalEmulatorView(session: session)
                    #else
                    Spacer()
                    #endif
                }
                .onDisappear { session.stop() }
            } else if let error = viewModel.loadError {
                Text(error)
                    .font(DSTypography.mono)
                    .foregroundStyle(.red)
            } else {
                ProgressView()
                    .tint(.white)
                    .task { await viewModel.load() }
            }
        }
        .navigationTitle("Terminal")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        #endif
    }
}

/// Compact status header: hostname + live connection state, Termius-style.
private struct TerminalStatusBar: View {
    let title: String
    let phase: TerminalConnectionPhase
    let onReconnect: () -> Void

    var body: some View {
        HStack(spacing: DSSpacing.sm) {
            Circle()
                .fill(statusColor)
                .frame(width: 9, height: 9)

            Text(title)
                .font(.system(.footnote, design: .monospaced))
                .foregroundStyle(.white)
                .lineLimit(1)
                .truncationMode(.middle)

            Spacer(minLength: DSSpacing.sm)

            Text(statusLabel)
                .font(.system(.caption2, design: .monospaced))
                .foregroundStyle(statusColor)

            if showReconnect {
                Button(action: onReconnect) {
                    Image(systemName: "arrow.clockwise")
                        .font(.caption)
                        .foregroundStyle(.white)
                }
                .accessibilityLabel("Reconnect")
            }
        }
        .padding(.horizontal, DSSpacing.md)
        .padding(.vertical, DSSpacing.sm)
        .background(Color(red: 0x14/255, green: 0x16/255, blue: 0x19/255))
    }

    private var showReconnect: Bool {
        switch phase {
        case .disconnected, .failed: return true
        default: return false
        }
    }

    private var statusLabel: String {
        switch phase {
        case .connecting: return "Connecting"
        case .connected: return "Connected"
        case let .reconnecting(attempt): return "Reconnecting \(attempt)"
        case .disconnected: return "Disconnected"
        case .failed: return "Failed"
        }
    }

    private var statusColor: Color {
        switch phase {
        case .connecting, .reconnecting: return .yellow
        case .connected: return .green
        case .disconnected, .failed: return .red
        }
    }
}
