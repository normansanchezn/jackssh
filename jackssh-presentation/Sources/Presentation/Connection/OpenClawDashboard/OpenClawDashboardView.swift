import SwiftUI
import DesignSystem
import WebKit

public struct OpenClawDashboardView: View {
    @State private var viewModel: OpenClawDashboardViewModel

    public init(viewModel: OpenClawDashboardViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        Group {
            switch viewModel.status {
            case .idle, .connectingTunnel:
                openingTunnelView
            case .ready:
                if let url = viewModel.dashboardURL {
                    OpenClawDashboardContent(
                        title: viewModel.host?.name ?? "OpenClaw",
                        tunnelDescription: viewModel.tunnelDescription,
                        dashboardURL: url
                    )
                } else {
                    unavailableView("Dashboard URL is not available")
                }
            case let .failed(message):
                unavailableView(message)
            }
        }
        .navigationTitle("OpenClaw")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .task { await viewModel.open() }
        .onDisappear {
            Task { await viewModel.close() }
        }
    }

    private var openingTunnelView: some View {
        VStack(spacing: DSSpacing.lg) {
            ProgressView()
            VStack(spacing: DSSpacing.xs) {
                Text("Opening secure bridge")
                    .font(DSTypography.sectionTitle)
                Text("Creating an SSH tunnel from this iPad to OpenClaw.")
                    .font(DSTypography.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(DSSpacing.lg)
    }

    private func unavailableView(_ message: String) -> some View {
        ContentUnavailableView(
            "Dashboard unavailable",
            systemImage: "point.topleft.down.curvedto.point.bottomright.up",
            description: Text(message)
        )
    }
}

private struct OpenClawDashboardContent: View {
    let title: String
    let tunnelDescription: String?
    let dashboardURL: URL

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: DSSpacing.md) {
                VStack(alignment: .leading, spacing: DSSpacing.xs) {
                    Text("OpenClaw Dashboard")
                        .font(DSTypography.sectionTitle)
                    Text(title)
                        .font(DSTypography.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if let tunnelDescription {
                    Label(tunnelDescription, systemImage: "lock.shield")
                        .font(DSTypography.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
            }
            .padding(DSSpacing.md)
            .background(.bar)

            WebViewContainer(url: dashboardURL)
        }
    }
}

#if os(iOS)
private struct WebViewContainer: UIViewRepresentable {
    let url: URL

    func makeUIView(context: UIViewRepresentableContext<WebViewContainer>) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.allowsBackForwardNavigationGestures = true
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: UIViewRepresentableContext<WebViewContainer>) {
        guard uiView.url != url else { return }
        uiView.load(URLRequest(url: url))
    }
}
#else
private struct WebViewContainer: View {
    let url: URL

    var body: some View {
        Text(url.absoluteString)
            .font(DSTypography.mono)
            .padding()
    }
}
#endif
