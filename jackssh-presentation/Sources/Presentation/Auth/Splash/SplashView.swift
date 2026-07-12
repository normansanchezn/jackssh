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
        ZStack {
            theme.colors.background
                .ignoresSafeArea()

            radialField

            VStack(spacing: DSSpacing.xxl) {
                Spacer()

                VStack(spacing: DSSpacing.xl) {
                    logoLockup
                    bootLine
                }
                .frame(maxWidth: 360)

                Spacer()

                VStack(spacing: DSSpacing.sm) {
                    Text(viewModel.uiState.statusText)
                        .font(DSTypography.caption.weight(.semibold))
                        .foregroundStyle(theme.colors.textSecondary)
                        .textCase(.uppercase)
                        .tracking(1.6)

                    loadingRail
                }
                .padding(.bottom, DSSpacing.xxl)
            }
            .padding(.horizontal, DSSpacing.xxl)
        }
    }

    private var logoLockup: some View {
        ZStack {
            Circle()
                .fill(.blue.opacity(isAnimating ? 0.18 : 0.08))
                .frame(width: 220, height: 220)
                .blur(radius: 32)
                .scaleEffect(isAnimating ? 1.08 : 0.86)
                .animation(.easeOut(duration: 0.8), value: isAnimating)

            Image("logo_jack_ssh", bundle: .module)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 320)
                .shadow(color: .blue.opacity(0.45), radius: isAnimating ? 24 : 4, x: 0, y: 10)
                .scaleEffect(isAnimating ? 1 : 0.92)
                .opacity(isAnimating ? 1 : 0)
                .animation(.easeOut(duration: 0.55), value: isAnimating)
        }
        .frame(height: 180)
        .accessibilityLabel("JackSSH")
    }

    private var bootLine: some View {
        HStack(spacing: DSSpacing.sm) {
            Text(">")
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundStyle(.green)

            Text("private ops console")
                .font(.system(.caption, design: .monospaced, weight: .semibold))
                .foregroundStyle(theme.colors.textSecondary)

            RoundedRectangle(cornerRadius: 1)
                .fill(.green)
                .frame(width: 9, height: 15)
                .opacity(isAnimating ? 0.15 : 1)
                .animation(.easeInOut(duration: 0.72).repeatForever(autoreverses: true), value: isAnimating)
        }
        .opacity(isAnimating ? 1 : 0)
        .offset(y: isAnimating ? 0 : 8)
        .animation(.easeOut(duration: 0.45).delay(0.12), value: isAnimating)
        .accessibilityHidden(true)
    }

    private var loadingRail: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(theme.colors.surfaceElevated.opacity(0.45))
                    .frame(height: 3)

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [.green, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * (isAnimating ? 0.82 : 0.12), height: 3)
                    .animation(.easeOut(duration: 0.9).delay(0.08), value: isAnimating)
            }
        }
        .frame(width: 180, height: 3)
        .accessibilityHidden(true)
    }

    private var radialField: some View {
        ZStack {
            Circle()
                .stroke(.blue.opacity(0.14), lineWidth: 1)
                .frame(width: 340, height: 340)
                .scaleEffect(isAnimating ? 1.04 : 0.86)
                .opacity(isAnimating ? 1 : 0)

            Circle()
                .stroke(.green.opacity(0.16), lineWidth: 1)
                .frame(width: 460, height: 460)
                .scaleEffect(isAnimating ? 1 : 0.8)
                .opacity(isAnimating ? 1 : 0)
        }
        .blur(radius: 0.4)
        .animation(.easeOut(duration: 0.8), value: isAnimating)
    }
}

#Preview("Splash") {
    SplashView().withJacksshThemeAutomatic()
}
