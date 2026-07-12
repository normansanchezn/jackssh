//
//  LoginUIState+Example.swift
//  jackssh-presentation
//
//  Ejemplo de cómo aplicar el mismo patrón a la pantalla de Login
//

import SwiftUI

/// Estado observable de la pantalla de Login
/// Este es un EJEMPLO de cómo aplicar el mismo patrón de localización
@MainActor
public final class LoginUIStateExample: ObservableObject {
    // MARK: - Published Properties
    @Published public var isLoading: Bool = false
    @Published public var error: Error? = nil
    
    // Textos localizados
    @Published public var title: String
    @Published public var emailPlaceholder: String
    @Published public var passwordPlaceholder: String
    @Published public var loginButtonText: String
    @Published public var forgotPasswordText: String
    @Published public var noAccountText: String
    
    // Estado del formulario
    @Published public var email: String = ""
    @Published public var password: String = ""
    @Published public var isFormValid: Bool = false
    
    // MARK: - Dependencies
    private let localizationManager: LocalizationManager
    
    // MARK: - Initialization
    public init(localizationManager: LocalizationManager = .shared) {
        self.localizationManager = localizationManager
        
        // Inicializa todos los textos localizados
        self.title = localizationManager.localized(LocalizationManager.Login.title)
        self.emailPlaceholder = localizationManager.localized(LocalizationManager.Login.emailPlaceholder)
        self.passwordPlaceholder = localizationManager.localized(LocalizationManager.Login.passwordPlaceholder)
        self.loginButtonText = localizationManager.localized(LocalizationManager.Login.loginButton)
        self.forgotPasswordText = localizationManager.localized("login.forgotPassword")
        self.noAccountText = localizationManager.localized("login.noAccount")
    }
    
    // MARK: - Public Methods
    
    public func validateForm() {
        isFormValid = !email.isEmpty && !password.isEmpty && email.contains("@")
    }
    
    public func reset() {
        isLoading = false
        error = nil
        email = ""
        password = ""
        isFormValid = false
    }
}

// MARK: - SignUp Example

/// Estado observable de la pantalla de SignUp
/// Este es un EJEMPLO de cómo aplicar el mismo patrón de localización
@MainActor
public final class SignUpUIStateExample: ObservableObject {
    // MARK: - Published Properties
    @Published public var isLoading: Bool = false
    @Published public var error: Error? = nil
    
    // Textos localizados
    @Published public var title: String
    @Published public var emailPlaceholder: String
    @Published public var passwordPlaceholder: String
    @Published public var confirmPasswordPlaceholder: String
    @Published public var signUpButtonText: String
    @Published public var hasAccountText: String
    
    // Estado del formulario
    @Published public var email: String = ""
    @Published public var password: String = ""
    @Published public var confirmPassword: String = ""
    @Published public var isFormValid: Bool = false
    
    // MARK: - Dependencies
    private let localizationManager: LocalizationManager
    
    // MARK: - Initialization
    public init(localizationManager: LocalizationManager = .shared) {
        self.localizationManager = localizationManager
        
        // Inicializa todos los textos localizados
        self.title = localizationManager.localized(LocalizationManager.SignUp.title)
        self.emailPlaceholder = localizationManager.localized(LocalizationManager.SignUp.emailPlaceholder)
        self.passwordPlaceholder = localizationManager.localized(LocalizationManager.SignUp.passwordPlaceholder)
        self.confirmPasswordPlaceholder = localizationManager.localized(LocalizationManager.SignUp.confirmPasswordPlaceholder)
        self.signUpButtonText = localizationManager.localized(LocalizationManager.SignUp.signUpButton)
        self.hasAccountText = localizationManager.localized("signup.hasAccount")
    }
    
    // MARK: - Public Methods
    
    public func validateForm() {
        isFormValid = !email.isEmpty 
            && !password.isEmpty 
            && !confirmPassword.isEmpty
            && email.contains("@")
            && password == confirmPassword
            && password.count >= 8
    }
    
    public func reset() {
        isLoading = false
        error = nil
        email = ""
        password = ""
        confirmPassword = ""
        isFormValid = false
    }
}

// MARK: - Ejemplo de uso con textos dinámicos

/// Ejemplo de UIState con textos que incluyen variables
@MainActor
public final class ProfileUIStateExample: ObservableObject {
    @Published public var greeting: String
    @Published public var messageCount: String
    
    private let localizationManager: LocalizationManager
    
    public init(
        userName: String = "Usuario",
        messages: Int = 0,
        localizationManager: LocalizationManager = .shared
    ) {
        self.localizationManager = localizationManager
        
        // Ejemplo de texto con una variable
        // En Localizable.strings: "profile.greeting" = "Hello, %@!";
        self.greeting = localizationManager.localized("profile.greeting", userName)
        
        // Ejemplo de texto con múltiples variables
        // En Localizable.strings: "profile.messages" = "You have %d new messages";
        self.messageCount = localizationManager.localized("profile.messages", messages)
    }
    
    /// Actualiza el saludo con un nuevo nombre
    public func updateGreeting(userName: String) {
        self.greeting = localizationManager.localized("profile.greeting", userName)
    }
    
    /// Actualiza el contador de mensajes
    public func updateMessageCount(_ count: Int) {
        self.messageCount = localizationManager.localized("profile.messages", count)
    }
}

// MARK: - Ejemplo con errores localizados

/// Extension para manejar mensajes de error localizados
extension LoginUIStateExample {
    
    /// Establece un error localizado
    /// - Parameter errorKey: Key del error en Localizable.strings
    public func setLocalizedError(_ errorKey: String) {
        let message = localizationManager.localized(errorKey)
        self.error = NSError(
            domain: "LoginError",
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: message]
        )
    }
    
    /// Errores predefinidos
    public enum ErrorKeys {
        static let invalidCredentials = "error.invalidCredentials"
        static let networkError = "error.network"
        static let unknownError = "error.unknown"
    }
}

// MARK: - Uso en Views (Ejemplos)

/*
// LoginView ejemplo
struct LoginViewExample: View {
    @ObservedObject var viewModel: LoginViewModel
    
    var body: some View {
        VStack {
            Text(viewModel.uiState.title)
                .font(.title)
            
            TextField(viewModel.uiState.emailPlaceholder, text: $viewModel.uiState.email)
            
            SecureField(viewModel.uiState.passwordPlaceholder, text: $viewModel.uiState.password)
            
            DSButton(viewModel.uiState.loginButtonText) {
                viewModel.login()
            }
            
            Button(viewModel.uiState.forgotPasswordText) {
                viewModel.forgotPassword()
            }
        }
    }
}

// SignUpView ejemplo
struct SignUpViewExample: View {
    @ObservedObject var viewModel: SignUpViewModel
    
    var body: some View {
        VStack {
            Text(viewModel.uiState.title)
                .font(.title)
            
            TextField(
                viewModel.uiState.emailPlaceholder, 
                text: $viewModel.uiState.email
            )
            
            SecureField(
                viewModel.uiState.passwordPlaceholder, 
                text: $viewModel.uiState.password
            )
            
            SecureField(
                viewModel.uiState.confirmPasswordPlaceholder, 
                text: $viewModel.uiState.confirmPassword
            )
            
            DSButton(viewModel.uiState.signUpButtonText) {
                viewModel.signUp()
            }
            .disabled(!viewModel.uiState.isFormValid)
        }
    }
}

// ProfileView ejemplo con textos dinámicos
struct ProfileViewExample: View {
    @ObservedObject var viewModel: ProfileViewModel
    
    var body: some View {
        VStack {
            Text(viewModel.uiState.greeting)
            Text(viewModel.uiState.messageCount)
        }
        .onAppear {
            viewModel.loadUserData()
        }
    }
}
*/
