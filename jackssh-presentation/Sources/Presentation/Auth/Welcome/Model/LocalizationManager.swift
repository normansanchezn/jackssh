//
//  LocalizationManager.swift
//  jackssh-presentation
//
//  Created by Norman Sánchez on 12/07/26.
//

import Foundation

public final class LocalizationManager: Sendable {
    
    public static let shared = LocalizationManager()
    private let bundle: Bundle
    
    public convenience init() {
        self.init(bundle: .module)
    }
    
    public init(bundle: Bundle) {
        self.bundle = bundle
    }
    
    public func localized(_ key: String, comment: String = "") -> String {
        NSLocalizedString(key, bundle: bundle, comment: comment)
    }
    
    public func localized(_ key: String, _ arguments: CVarArg...) -> String {
        let format = NSLocalizedString(key, bundle: bundle, comment: "")
        return String(format: format, arguments: arguments)
    }
}

extension LocalizationManager {
    public enum Welcome {
        public static let title = "welcome.title"
        public static let subtitle = "welcome.subtitle"
        public static let signIn = "welcome.signIn"
        public static let signUp = "welcome.signUp"
    }
    
    public enum Login {
        public static let title = "login.title"
        public static let emailPlaceholder = "login.email.placeholder"
        public static let passwordPlaceholder = "login.password.placeholder"
        public static let loginButton = "login.button"
    }
    
    public enum SignUp {
        public static let title = "signup.title"
        public static let emailPlaceholder = "signup.email.placeholder"
        public static let passwordPlaceholder = "signup.password.placeholder"
        public static let confirmPasswordPlaceholder = "signup.confirmPassword.placeholder"
        public static let signUpButton = "signup.button"
    }
}
