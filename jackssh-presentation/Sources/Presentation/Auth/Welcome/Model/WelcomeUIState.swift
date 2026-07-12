//
//  WelcomeUIState.swift
//  jackssh-presentation
//
//  Created by Norman Sánchez on 12/07/26.
//

import SwiftUI

/// Estado observable de la pantalla de Welcome
@MainActor
public final class WelcomeUIState: ObservableObject {
    @Published public var isLoading: Bool = false
    @Published public var error: Error? = nil
    @Published public var title: String
    @Published public var subtitle: String
    @Published public var signInButtonText: String
    @Published public var signUpButtonText: String
    @Published public var showSignIn: Bool = false
    @Published public var showSignUp: Bool = false
    
    private let localizationManager: LocalizationManager
    
    public init(localizationManager: LocalizationManager = .shared) {
        self.localizationManager = localizationManager
        
        self.title = localizationManager.localized(LocalizationManager.Welcome.title)
        self.subtitle = localizationManager.localized(LocalizationManager.Welcome.subtitle)
        self.signInButtonText = localizationManager.localized(LocalizationManager.Welcome.signIn)
        self.signUpButtonText = localizationManager.localized(LocalizationManager.Welcome.signUp)
    }
    
    public func reset() {
        isLoading = false
        error = nil
        showSignIn = false
        showSignUp = false
    }
}
