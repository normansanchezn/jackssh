//
//  WelcomeEffect.swift
//  jackssh-presentation
//
//  Created by Norman Sánchez on 12/07/26.
//

import Foundation

public enum WelcomeEffect: Equatable {
    case navigateToSignIn
    case navigateToSignUp
    case showError(message: String)
    case none
}
