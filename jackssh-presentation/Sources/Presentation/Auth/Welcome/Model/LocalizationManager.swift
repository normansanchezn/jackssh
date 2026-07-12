//
//  LocalizationManager.swift
//  jackssh-presentation
//
//  Created by Norman Sánchez on 12/07/26.
//

import Foundation

/// Manager centralizado para manejar la localización de strings.
/// Por defecto lee los recursos incluidos en el módulo Presentation.
public final class LocalizationManager: Sendable {
    
    // MARK: - Singleton
    public static let shared = LocalizationManager()
    
    // MARK: - Properties
    private let bundle: Bundle
    
    // MARK: - Initialization
    
    /// Inicializador por defecto que usa el bundle del módulo Presentation.
    public convenience init() {
        self.init(bundle: .module)
    }
    
    /// Inicializador con bundle personalizado (útil para testing)
    /// - Parameter bundle: Bundle donde se encuentra Localizable.xcstrings
    public init(bundle: Bundle) {
        self.bundle = bundle
    }
    
    // MARK: - Public Methods
    
    /// Obtiene un string localizado del bundle configurado.
    /// - Parameters:
    ///   - key: Clave del string en Localizable.xcstrings
    ///   - comment: Comentario opcional para ayudar a los traductores
    /// - Returns: String localizado o la clave si no se encuentra
    public func localized(_ key: String, comment: String = "") -> String {
        NSLocalizedString(key, bundle: bundle, comment: comment)
    }
    
    /// Obtiene un string localizado con interpolación de valores.
    /// - Parameters:
    ///   - key: Clave del string en Localizable.xcstrings
    ///   - arguments: Valores a interpolar en el string
    /// - Returns: String localizado con valores interpolados
    public func localized(_ key: String, _ arguments: CVarArg...) -> String {
        let format = NSLocalizedString(key, bundle: bundle, comment: "")
        return String(format: format, arguments: arguments)
    }
}

// MARK: - Convenience Extensions

extension LocalizationManager {
    
    /// Namespace para las keys de Welcome
    public enum Welcome {
        public static let title = "welcome.title"
        public static let subtitle = "welcome.subtitle"
        public static let signIn = "welcome.signIn"
        public static let signUp = "welcome.signUp"
    }
    
    /// Namespace para las keys de Login (ejemplo para futuro)
    public enum Login {
        public static let title = "login.title"
        public static let emailPlaceholder = "login.email.placeholder"
        public static let passwordPlaceholder = "login.password.placeholder"
        public static let loginButton = "login.button"
    }
    
    /// Namespace para las keys de SignUp (ejemplo para futuro)
    public enum SignUp {
        public static let title = "signup.title"
        public static let emailPlaceholder = "signup.email.placeholder"
        public static let passwordPlaceholder = "signup.password.placeholder"
        public static let confirmPasswordPlaceholder = "signup.confirmPassword.placeholder"
        public static let signUpButton = "signup.button"
    }
}
