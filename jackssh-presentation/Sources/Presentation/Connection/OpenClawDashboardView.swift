import SwiftUI
import Domain
import DesignSystem
import WebKit

public struct OpenClawDashboardView: View {
    @State private var viewModel: ConnectedHostViewModel
    private let dependencies: HostsDependencies

    public init(hostID: UUID, dependencies: HostsDependencies) {
        _viewModel = State(initialValue: dependencies.makeConnectedViewModel(hostID))
        self.dependencies = dependencies
    }

    public var body: some View {
        if let session = viewModel.session, let host = viewModel.host, let config = host.openClawConfiguration {
            OpenClawDashboardContent(session: session, host: host, config: config)
        } else {
            ProgressView()
                .task { await viewModel.load() }
        }
    }
}

struct OpenClawDashboardContent: View {
    private let session: ConnectedHostSession
    private let host: Domain.Host
    private let config: OpenClawConfiguration

    init(session: ConnectedHostSession, host: Domain.Host, config: OpenClawConfiguration) {
        self.session = session
        self.host = host
        self.config = config
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                Text("OpenClaw Dashboard")
                    .font(DSTypography.sectionTitle)
                Text(host.name)
                    .font(DSTypography.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(DSSpacing.md)

            Divider()

            WebViewContainer(url: dashboardURL)
                .navigationTitle("Dashboard")
        }
    }

    private var dashboardURL: URL {
        let scheme = config.scheme
        let host = config.host
        let port = config.port
        let basePath = config.basePath
        let urlString = "\(scheme)://\(host):\(port)\(basePath)"
        return URL(string: urlString) ?? URL(string: "about:blank")!
    }
}

struct WebViewContainer: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        let request = URLRequest(url: url)
        webView.load(request)
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}
