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
            TerminalViewContainer(hostID: uuid, dependencies: dependencies)
        } else {
            Text("Invalid host ID")
        }
    }
}

struct TerminalViewContainer: View {
    @State private var viewModel: ConnectedHostViewModel
    private let dependencies: HostsDependencies

    init(hostID: UUID, dependencies: HostsDependencies) {
        _viewModel = State(initialValue: dependencies.makeConnectedViewModel(hostID))
        self.dependencies = dependencies
    }

    var body: some View {
        if let session = viewModel.session, let host = viewModel.host {
            TerminalContentView(session: session, host: host)
        } else {
            ProgressView()
                .task { await viewModel.load() }
        }
    }
}

struct TerminalContentView: View {
    @State private var terminalViewModel: TerminalViewModel
    private let session: ConnectedHostSession
    private let host: Domain.Host

    init(session: ConnectedHostSession, host: Domain.Host) {
        self.session = session
        self.host = host
        _terminalViewModel = State(initialValue: TerminalViewModel(session: session))
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                Text("Terminal")
                    .font(DSTypography.sectionTitle)
                Text(host.name)
                    .font(DSTypography.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(DSSpacing.md)

            Divider()

            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: DSSpacing.xs) {
                        ForEach(terminalViewModel.output) { line in
                            HStack(spacing: 0) {
                                if line.isPrompt {
                                    Text("$ ")
                                        .font(DSTypography.mono)
                                        .foregroundStyle(.green)
                                }
                                Text(line.text)
                                    .font(DSTypography.mono)
                                    .foregroundStyle(line.isPrompt ? .white : .gray)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .id(line.id)
                        }
                    }
                    .padding(DSSpacing.md)
                }
                .background(Color.black)
                .onChange(of: terminalViewModel.output) { _, _ in
                    if let lastID = terminalViewModel.output.last?.id {
                        withAnimation {
                            proxy.scrollTo(lastID, anchor: .bottom)
                        }
                    }
                }
            }

            HStack(spacing: DSSpacing.sm) {
                TextField("Command", text: $terminalViewModel.command)
                    .font(DSTypography.mono)
                    .textFieldStyle(.roundedBorder)
                    .disabled(terminalViewModel.isExecuting)
                Button {
                    Task { await terminalViewModel.executeCommand() }
                } label: {
                    Image(systemName: terminalViewModel.isExecuting ? "hourglass" : "arrow.up.circle.fill")
                }
                .disabled(terminalViewModel.isExecuting || terminalViewModel.command.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(DSSpacing.md)
        }
        .navigationTitle("Terminal")
    }
}
