import SwiftUI
import Domain
import DesignSystem

public struct ConnectingHostView: View {
    @State private var viewModel: ConnectingHostViewModel
    @Environment(AppRouter.self) private var router
    @Environment(\.jacksshTheme) private var theme
    @State private var showErrorAlert = false
    @State private var errorMessage = ""

    public init(viewModel: ConnectingHostViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        ZStack {
            theme.colors.background.ignoresSafeArea()
            VStack(spacing: DSSpacing.lg) {
                if let host = viewModel.host {
                    Text("Connecting to \(host.name)")
                        .font(DSTypography.sectionTitle)
                }

                VStack(alignment: .leading, spacing: DSSpacing.md) {
                    stateRow("Resolving host", state: viewModel.state, position: 0)
                    stateRow("Verifying server identity", state: viewModel.state, position: 1)
                    stateRow("Authenticating", state: viewModel.state, position: 2)
                    stateRow("Opening session", state: viewModel.state, position: 3)
                    stateRow("Preparing workspace", state: viewModel.state, position: 4)
                }
                .padding(DSSpacing.md)

                Spacer()

                HStack(spacing: DSSpacing.md) {
                    Button(role: .cancel) {
                        viewModel.cancel()
                        router.popToRoot()
                    } label: {
                        Text("Cancel")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)

                    if case let .failed(failure) = viewModel.state, failure.canRetry {
                        Button {
                            Task { await viewModel.retry() }
                        } label: {
                            Text("Retry")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding(DSSpacing.md)
            }
            .padding(DSSpacing.lg)
        }
        .alert("Connection Failed", isPresented: $showErrorAlert) {
            Button("Retry") { Task { await viewModel.retry() } }
            Button("Cancel", role: .cancel) { router.popToRoot() }
        } message: {
            Text(errorMessage)
        }
        .task {
            await viewModel.connect()
        }
        .onChange(of: viewModel.state) { oldValue, newValue in
            if case let .connected(session) = newValue {
                router.replaceTop(with: .connected(hostID: session.hostID.uuidString))
            } else if case let .failed(failure) = newValue {
                errorMessage = failure.description
                showErrorAlert = true
            }
        }
    }

    private func stateRow(_ label: String, state: HostConnectionState, position: Int) -> some View {
        HStack(spacing: DSSpacing.sm) {
            image(for: state, position: position)
                .frame(width: 20)
            Text(label)
                .font(DSTypography.body)
            Spacer()
        }
    }

    private func image(for state: HostConnectionState, position: Int) -> Image {
        let currentPosition = connectionPosition(state)
        if currentPosition > position {
            return Image(systemName: "checkmark.circle.fill")
        } else if currentPosition == position {
            return Image(systemName: "circle.fill")
        } else {
            return Image(systemName: "circle")
        }
    }

    private func connectionPosition(_ state: HostConnectionState) -> Int {
        switch state {
        case .idle: return -1
        case .resolving: return 0
        case .verifyingHostKey, .awaitingHostTrust: return 1
        case .authenticating: return 2
        case .openingSession: return 3
        case .preparingWorkspace: return 4
        case .connected: return 5
        case .failed, .cancelled: return -1
        }
    }
}

#Preview("Connecting host") {
    let router = AppRouter()
    return NavigationStack {
        ConnectingHostView(viewModel: PreviewFixtures.hostsDependencies().makeConnectingViewModel(PreviewFixtures.host.id))
            .environment(router)
    }
    .withJacksshThemeAutomatic()
}
