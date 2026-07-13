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
            case .idle, .connectingTunnel, .preparingAuthentication:
                openingTunnelView
            case .ready:
                if let url = viewModel.dashboardURL {
                    OpenClawDashboardContent(
                        title: viewModel.host?.name ?? "OpenClaw",
                        tunnelDescription: viewModel.tunnelDescription,
                        dashboardURL: url,
                        authToken: viewModel.authToken
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
    let authToken: String?

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

            WebViewContainer(url: dashboardURL, authToken: authToken)
        }
    }
}

#if os(iOS)
private struct WebViewContainer: UIViewRepresentable {
    let url: URL
    let authToken: String?

    func makeUIView(context: UIViewRepresentableContext<WebViewContainer>) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        if let authToken, !authToken.isEmpty {
            configuration.userContentController.addUserScript(Self.authScript(token: authToken))
        }
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.allowsBackForwardNavigationGestures = true
        load(url, authToken: authToken, in: webView)
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: UIViewRepresentableContext<WebViewContainer>) {
        guard uiView.url != url else { return }
        load(url, authToken: authToken, in: uiView)
    }

    private func load(_ url: URL, authToken: String?, in webView: WKWebView) {
        guard let authToken, !authToken.isEmpty,
              let host = url.host
        else {
            webView.load(URLRequest(url: url))
            return
        }

        let cookie = HTTPCookie(properties: [
            .domain: host,
            .path: "/",
            .name: "openclaw_token",
            .value: authToken,
            .secure: url.scheme == "https",
            .expires: Date().addingTimeInterval(60 * 60),
        ])

        if let cookie {
            webView.configuration.websiteDataStore.httpCookieStore.setCookie(cookie) {
                webView.load(Self.request(url: url, token: authToken))
            }
        } else {
            webView.load(Self.request(url: url, token: authToken))
        }
    }

    private static func request(url: URL, token: String) -> URLRequest {
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }

    private static func authScript(token: String) -> WKUserScript {
        let encoded = token
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "'", with: "\\'")
            .replacingOccurrences(of: "\n", with: "\\n")
        let source = """
        (function() {
          var token = '\(encoded)';
          try {
            localStorage.setItem('openclaw_token', token);
            localStorage.setItem('token', token);
            localStorage.setItem('authToken', token);
            localStorage.setItem('access_token', token);
            sessionStorage.setItem('openclaw_token', token);
            document.cookie = 'openclaw_token=' + encodeURIComponent(token) + '; path=/; SameSite=Lax';
            document.cookie = 'token=' + encodeURIComponent(token) + '; path=/; SameSite=Lax';
          } catch (_) {}
        })();
        """
        return WKUserScript(source: source, injectionTime: .atDocumentStart, forMainFrameOnly: false)
    }
}
#else
private struct WebViewContainer: View {
    let url: URL
    let authToken: String?

    var body: some View {
        Text(url.absoluteString)
            .font(DSTypography.mono)
            .padding()
    }
}
#endif
