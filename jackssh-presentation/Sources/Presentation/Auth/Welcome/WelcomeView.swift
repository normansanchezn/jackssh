import SwiftUI
import DesignSystem

public struct WelcomeView: View {
    @StateObject private var viewModel: WelcomeViewModel
    let onSignIn: () -> Void
    let onSignUp: () -> Void

    public init(
        viewModel: WelcomeViewModel = WelcomeViewModel(),
        onSignIn: @escaping () -> Void,
        onSignUp: @escaping () -> Void
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onSignIn = onSignIn
        self.onSignUp = onSignUp
    }

    public var body: some View {
        _WelcomeContent(
            viewModel: viewModel,
            onSignIn: onSignIn,
            onSignUp: onSignUp
        )
        .onChange(of: viewModel.effect) { _, newEffect in
            handleEffect(newEffect)
        }
    }
    
    // MARK: - Effect Handling
    private func handleEffect(_ effect: WelcomeEffect) {
        switch effect {
        case .navigateToSignIn:
            onSignIn()
            viewModel.clearEffect()
            
        case .navigateToSignUp:
            onSignUp()
            viewModel.clearEffect()
            
        case .showError(let message):
            // Aquí puedes mostrar un alert o toast
            print("Error: \(message)")
            viewModel.clearEffect()
            
        case .none:
            break
        }
    }
}

struct _WelcomeContent: View {
    @Environment(\.jacksshTheme) var theme
    @ObservedObject var viewModel: WelcomeViewModel
    let onSignIn: () -> Void
    let onSignUp: () -> Void

    var body: some View {
        DSBackground(showGrid: true) {
            VStack(spacing: DSSpacing.lg) {
                Spacer()

                VStack(spacing: DSSpacing.md) {
                    Image(systemName: "terminal.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(.blue)

                    Text(viewModel.uiState.title)
                        .font(DSTypography.screenTitle)
                        .multilineTextAlignment(.center)

                    Text(viewModel.uiState.subtitle)
                        .font(DSTypography.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(DSSpacing.lg)

                Spacer()

                VStack(spacing: DSSpacing.md) {
                    DSButton(
                        "Sign In",
                        icon: "arrow.right.circle.fill",
                        style: .filled,
                        fullWidth: true
                    ) {
                        viewModel.onSignInTapped()
                    }
                    .disabled(viewModel.uiState.isLoading)

                    DSButton(
                        "Create Account",
                        icon: "person.badge.plus",
                        style: .outline,
                        fullWidth: true
                    ) {
                        viewModel.onSignUpTapped()
                    }
                    .disabled(viewModel.uiState.isLoading)
                }
                .padding(DSSpacing.lg)
            }
            .overlay {
                if viewModel.uiState.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.2))
                }
            }
        }
    }
}

#Preview("Welcome") {
    WelcomeView(onSignIn: {}, onSignUp: {})
        .withJacksshThemeAutomatic()
}
