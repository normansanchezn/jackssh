import SwiftUI
import DesignSystem
import Domain

public struct LoginView: View {
    @State private var viewModel: AuthViewModel
    @Environment(\.jacksshTheme) var theme
    @State private var isBiometricEnrollmentAlertPresented = false
    @State private var showsPasswordSignIn = false
    let onSuccess: () -> Void
    let onSignUp: () -> Void

    public init(viewModel: AuthViewModel, onSuccess: @escaping () -> Void, onSignUp: @escaping () -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onSuccess = onSuccess
        self.onSignUp = onSignUp
    }

    public var body: some View {
        AuthAdaptiveLayout(
            title: "Sign In",
            subtitle: "Access your private operations workspace."
        ) {
            content()
        }
        .task {
            await viewModel.loadBiometricState()
        }
        .alert(
            "Enable \(viewModel.biometricAvailability.biometryName)?",
            isPresented: $isBiometricEnrollmentAlertPresented
        ) {
            Button("Not Now", role: .cancel) {
                viewModel.dismissBiometricEnrollmentOffer()
                onSuccess()
            }
            Button("Enable") {
                Task {
                    await viewModel.enableBiometricLoginForCurrentCredentials()
                    onSuccess()
                }
            }
        } message: {
            Text("Use \(viewModel.biometricAvailability.biometryName) to unlock your JackSSH sign-in on this device.")
        }
    }
    
    private func content() -> some View {
        VStack(spacing: DSSpacing.lg) {
            if viewModel.biometricAvailability.isEnabled && !showsPasswordSignIn {
                biometricPrimarySignIn
                LoginCaptionAction(title: "Sign in with email and password") {
                    withAnimation(.easeOut(duration: 0.18)) {
                        showsPasswordSignIn = true
                    }
                }
            } else {
                passwordSignInContent
            }

            if let error = viewModel.error {
                Text(error)
                    .font(DSTypography.caption)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            if !viewModel.biometricAvailability.isEnabled || showsPasswordSignIn {
                DSButton(
                    "Don't have an account? Sign Up",
                    style: .text
                ) {
                    onSignUp()
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var biometricPrimarySignIn: some View {
        Button {
            Task {
                await viewModel.loginWithBiometrics()
                if case .authenticated = viewModel.authState {
                    onSuccess()
                }
            }
        } label: {
            VStack(spacing: DSSpacing.md) {
                Image(systemName: biometricIcon)
                    .font(.system(size: 58, weight: .regular))
                    .foregroundStyle(theme.colors.primary600)
                    .frame(width: 96, height: 96)
                    .background(theme.colors.primary600.opacity(0.12), in: RoundedRectangle(cornerRadius: DSRadius.lg, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: DSRadius.lg, style: .continuous)
                            .stroke(theme.colors.primary600.opacity(0.38), lineWidth: 1)
                    }

                Text("Sign in with \(viewModel.biometricAvailability.biometryName)")
                    .font(DSTypography.sectionTitle)
                    .foregroundStyle(theme.colors.textPrimary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DSSpacing.lg)
        }
        .buttonStyle(.plain)
        .disabled(viewModel.isLoading)
        .accessibilityHint("Authenticates using credentials protected by \(viewModel.biometricAvailability.biometryName)")
    }

    private var passwordSignInContent: some View {
        VStack(spacing: DSSpacing.lg) {
            VStack(spacing: DSSpacing.md) {
                TextField("Email", text: $viewModel.email)
                    .autocorrectionDisabled()
                    .padding(DSSpacing.md)
                    .background(theme.colors.surfaceElevated.opacity(0.8))
                    .cornerRadius(DSRadius.sm)
                    .overlay(
                        RoundedRectangle(cornerRadius: DSRadius.sm)
                            .stroke(theme.colors.border, lineWidth: 1)
                    )

                SecureField("Password", text: $viewModel.password)
                    .padding(DSSpacing.md)
                    .background(theme.colors.surfaceElevated.opacity(0.8))
                    .cornerRadius(DSRadius.sm)
                    .overlay(
                        RoundedRectangle(cornerRadius: DSRadius.sm)
                            .stroke(theme.colors.border, lineWidth: 1)
                    )
            }

            DSButton(
                "Sign In",
                icon: "arrow.right.circle.fill",
                style: .filled,
                fullWidth: true,
                isLoading: viewModel.isLoading
            ) {
                Task {
                    await viewModel.login()
                    if viewModel.shouldOfferBiometricEnrollment {
                        isBiometricEnrollmentAlertPresented = true
                    } else if case .authenticated = viewModel.authState {
                        onSuccess()
                    }
                }
            }
        }
    }

    private var biometricIcon: String {
        switch viewModel.biometricAvailability.biometryName {
        case "Face ID":
            return "faceid"
        case "Touch ID":
            return "touchid"
        default:
            return "lock.shield"
        }
    }
}
