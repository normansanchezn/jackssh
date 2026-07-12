import SwiftUI
import DesignSystem
import Domain

public struct LoginView: View {
    @State private var viewModel: AuthViewModel
    @Environment(\.jacksshTheme) var theme
    @State private var isBiometricEnrollmentAlertPresented = false
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
            VStack(spacing: DSSpacing.md) {
                TextField("Email", text: $viewModel.email)
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

            if let error = viewModel.error {
                Text(error)
                    .font(DSTypography.caption)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            VStack(spacing: DSSpacing.md) {
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

                if viewModel.biometricAvailability.isEnabled {
                    DSButton(
                        "Sign in with \(viewModel.biometricAvailability.biometryName)",
                        icon: biometricIcon,
                        style: .outline,
                        fullWidth: true,
                        isLoading: viewModel.isLoading
                    ) {
                        Task {
                            await viewModel.loginWithBiometrics()
                            if case .authenticated = viewModel.authState {
                                onSuccess()
                            }
                        }
                    }
                    .accessibilityHint("Authenticates using credentials protected by \(viewModel.biometricAvailability.biometryName)")
                }

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
