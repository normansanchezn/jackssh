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
    @State private var keyboardMode: TerminalKeyboardMode = .qwerty
    private let embedded: Bool

    init(viewModel: TerminalViewModel, embedded: Bool = false) {
        _viewModel = State(initialValue: viewModel)
        self.embedded = embedded
    }

    var body: some View {
        ZStack {
            terminalBackground

            if let session = viewModel.session {
                VStack(spacing: 0) {
                    TerminalStatusBar(
                        title: viewModel.connectionTitle,
                        phase: session.phase,
                        keyboardMode: $keyboardMode,
                        onReconnect: { session.reconnectNow() }
                    )
                    #if os(iOS)
                    TerminalEmulatorView(session: session)
                    if keyboardMode == .terminal {
                        TerminalKeyboardPanel(session: session)
                    }
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
        .modifier(TerminalNavigationModifier(isEmbedded: embedded))
        .clipped()
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        #endif
    }

    @ViewBuilder
    private var terminalBackground: some View {
        let color = Color(red: 0x02/255, green: 0x05/255, blue: 0x0B/255)
        if embedded {
            color
        } else {
            color.ignoresSafeArea(.container)
        }
    }
}

private struct TerminalNavigationModifier: ViewModifier {
    let isEmbedded: Bool

    @ViewBuilder
    func body(content: Content) -> some View {
        if isEmbedded {
            content
        } else {
            content.navigationTitle("Terminal")
        }
    }
}

private enum TerminalKeyboardMode: String, CaseIterable {
    case qwerty = "QWERTY"
    case terminal = "Terminal"
}

/// Compact status header: hostname + live connection state, Termius-style.
private struct TerminalStatusBar: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    let title: String
    let phase: TerminalConnectionPhase
    @Binding var keyboardMode: TerminalKeyboardMode
    let onReconnect: () -> Void

    var body: some View {
        content
        .padding(.horizontal, DSSpacing.md)
        .padding(.vertical, DSSpacing.sm)
        .background(Color(red: 0x08/255, green: 0x0D/255, blue: 0x14/255))
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(.white.opacity(0.08))
                .frame(height: 1)
        }
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

    @ViewBuilder
    private var content: some View {
        if horizontalSizeClass == .compact {
            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                HStack(spacing: DSSpacing.sm) {
                    connectionIdentity
                    Spacer(minLength: DSSpacing.sm)
                    reconnectButton
                }
                keyboardPicker(width: nil)
            }
        } else {
            HStack(spacing: DSSpacing.sm) {
                connectionIdentity
                Spacer(minLength: DSSpacing.sm)
                keyboardPicker(width: 154)
                reconnectButton
            }
        }
    }

    private var connectionIdentity: some View {
        HStack(spacing: DSSpacing.sm) {
            Circle()
                .fill(statusColor)
                .frame(width: 9, height: 9)
            Text(title)
                .font(.system(.footnote, design: .monospaced))
                .foregroundStyle(.white)
                .lineLimit(1)
                .truncationMode(.middle)
            Text(statusLabel)
                .font(.system(.caption2, design: .monospaced))
                .foregroundStyle(statusColor)
                .lineLimit(1)
        }
    }

    private func keyboardPicker(width: CGFloat?) -> some View {
        Picker("Keyboard", selection: $keyboardMode) {
            ForEach(TerminalKeyboardMode.allCases, id: \.self) { mode in
                Text(mode.rawValue).tag(mode)
            }
        }
        .pickerStyle(.segmented)
        .frame(width: width)
        .accessibilityLabel("Keyboard mode")
    }

    @ViewBuilder
    private var reconnectButton: some View {
        if showReconnect {
            Button(action: onReconnect) {
                Image(systemName: "arrow.clockwise")
                    .font(.caption)
                    .foregroundStyle(.white)
            }
            .accessibilityLabel("Reconnect")
        }
    }
}

#if os(iOS)
private struct TerminalKeyboardPanel: View {
    @Environment(\.jacksshTheme) private var theme
    let session: TerminalSession

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 7) {
                ForEach(TerminalKey.primaryKeys) { key in
                    Button {
                        session.sendBytes(key.bytes)
                    } label: {
                        Text(key.title)
                            .font(.system(size: 12, weight: .semibold, design: .monospaced))
                            .foregroundStyle(key.role == .destructive ? theme.colors.statusDisconnected : theme.colors.textPrimary)
                            .frame(minWidth: key.width, minHeight: 34)
                            .padding(.horizontal, 4)
                            .background(theme.colors.surface.opacity(0.86), in: RoundedRectangle(cornerRadius: DSRadius.xs, style: .continuous))
                            .overlay {
                                RoundedRectangle(cornerRadius: DSRadius.xs, style: .continuous)
                                    .stroke(theme.colors.border.opacity(0.65), lineWidth: 1)
                            }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(key.accessibilityLabel)
                }
            }
            .padding(.horizontal, DSSpacing.md)
            .padding(.vertical, DSSpacing.sm)
        }
        .background(Color(red: 0x05/255, green: 0x09/255, blue: 0x10/255))
        .overlay(alignment: .top) {
            Rectangle()
                .fill(.white.opacity(0.08))
                .frame(height: 1)
        }
    }
}

private struct TerminalKey: Identifiable {
    enum Role {
        case normal
        case destructive
    }

    let id: String
    let title: String
    let bytes: [UInt8]
    let width: CGFloat
    let role: Role
    let accessibilityLabel: String

    init(_ title: String, bytes: [UInt8], width: CGFloat = 38, role: Role = .normal, accessibilityLabel: String? = nil) {
        self.id = title
        self.title = title
        self.bytes = bytes
        self.width = width
        self.role = role
        self.accessibilityLabel = accessibilityLabel ?? title
    }

    static let primaryKeys: [TerminalKey] = [
        TerminalKey("Esc", bytes: [0x1B], accessibilityLabel: "Escape"),
        TerminalKey("Tab", bytes: [0x09], accessibilityLabel: "Tab"),
        TerminalKey("^C", bytes: [0x03], width: 42, role: .destructive, accessibilityLabel: "Control C"),
        TerminalKey("^L", bytes: [0x0C], width: 42, accessibilityLabel: "Control L"),
        TerminalKey("↑", bytes: Array("\u{1B}[A".utf8), accessibilityLabel: "Arrow up"),
        TerminalKey("↓", bytes: Array("\u{1B}[B".utf8), accessibilityLabel: "Arrow down"),
        TerminalKey("←", bytes: Array("\u{1B}[D".utf8), accessibilityLabel: "Arrow left"),
        TerminalKey("→", bytes: Array("\u{1B}[C".utf8), accessibilityLabel: "Arrow right"),
        TerminalKey("/", bytes: Array("/".utf8)),
        TerminalKey("-", bytes: Array("-".utf8)),
        TerminalKey("_", bytes: Array("_".utf8)),
        TerminalKey("|", bytes: Array("|".utf8)),
        TerminalKey("~", bytes: Array("~".utf8)),
        TerminalKey("Enter", bytes: [0x0D], width: 58, accessibilityLabel: "Enter"),
    ]
}
#endif
