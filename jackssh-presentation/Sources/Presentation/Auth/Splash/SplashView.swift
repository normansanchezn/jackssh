import SwiftUI
import DesignSystem

public struct SplashView: View {
    @State private var viewModel: SplashViewModel

    public init(viewModel: SplashViewModel = SplashViewModel()) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        _SplashContent(viewModel: viewModel)
            .task {
                viewModel.start()
            }
    }
}

private struct _SplashContent: View {
    @Environment(\.jacksshTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let viewModel: SplashViewModel

    private var isAnimating: Bool {
        viewModel.uiState.isAnimating && !reduceMotion
    }

    var body: some View {
        DSBackground {
            VStack(
                alignment: .center,
                spacing: DSSpacing.xxl
            ) {
                logoLockup
            }
            .padding(.horizontal, DSSpacing.xxl)
        }
    }

    private var logoLockup: some View {
        ZStack {
            Circle()
                .fill(theme.colors.primary600.opacity(isAnimating ? 0.18 : 0.08))
                .frame(width: 220, height: 220)
                .blur(radius: 32)
                .scaleEffect(isAnimating ? 1.08 : 0.86)
                .animation(.easeOut(duration: 0.8), value: isAnimating)

            Image("logo_jack_ssh", bundle: .module)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 320)
                .shadow(color: theme.colors.primary600.opacity(0.45), radius: isAnimating ? 24 : 4, x: 0, y: 10)
                .scaleEffect(isAnimating ? 1 : 0.92)
                .opacity(isAnimating ? 1 : 0)
                .animation(.easeOut(duration: 0.55), value: isAnimating)
        }
        .frame(height: 180)
        .accessibilityLabel("JackSSH")
    }
}

#Preview("Splash") {
    SplashView().withJacksshThemeAutomatic()
}
