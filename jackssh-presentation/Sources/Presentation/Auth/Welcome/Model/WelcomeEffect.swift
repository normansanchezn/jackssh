//
//  WelcomeEffect.swift
//  jackssh-presentation
//
//  Created by Norman Sánchez on 12/07/26.
//

import Foundation

/// Efectos/Eventos one-shot que ocurren en la pantalla de Welcome
public enum WelcomeEffect: Equatable {
    case navigateToSignIn
    case navigateToSignUp
    case showError(message: String)
    case none
}
