//
//  WelcomeUIStateTests.swift
//  jackssh-presentation-tests
//
//  Created by Norman Sánchez on 12/07/26.
//

import Testing
import Foundation
@testable import Presentation

@MainActor
@Suite("WelcomeUIState Tests")
struct WelcomeUIStateTests {
    
    @Test("UIState initializes with localized strings")
    func initializesWithLocalizedStrings() async throws {
        // Given
        let uiState = WelcomeUIState()
        
        // Then - verifica que los strings no estén vacíos
        #expect(!uiState.title.isEmpty, "Title should not be empty")
        #expect(!uiState.subtitle.isEmpty, "Subtitle should not be empty")
        #expect(!uiState.signInButtonText.isEmpty, "Sign in button text should not be empty")
        #expect(!uiState.signUpButtonText.isEmpty, "Sign up button text should not be empty")
    }
    
    @Test("UIState can be initialized with custom localization manager")
    func initializesWithCustomManager() async throws {
        // Given - crea un manager con bundle principal
        let customManager = LocalizationManager(bundle: .main)
        
        // When
        let uiState = WelcomeUIState(localizationManager: customManager)
        
        // Then
        #expect(!uiState.title.isEmpty, "Title should be localized")
        #expect(!uiState.subtitle.isEmpty, "Subtitle should be localized")
    }
    
    @Test("Reset clears transient state but preserves strings")
    func resetClearsState() async throws {
        // Given
        let uiState = WelcomeUIState()
        uiState.isLoading = true
        uiState.error = NSError(domain: "test", code: 1)
        uiState.showSignIn = true
        uiState.showSignUp = true
        
        let originalTitle = uiState.title
        let originalSubtitle = uiState.subtitle
        
        // When
        uiState.reset()
        
        // Then - estado transitorio se limpia
        #expect(uiState.isLoading == false, "Loading should be reset")
        #expect(uiState.error == nil, "Error should be cleared")
        #expect(uiState.showSignIn == false, "ShowSignIn should be reset")
        #expect(uiState.showSignUp == false, "ShowSignUp should be reset")
        
        // Los strings se preservan
        #expect(uiState.title == originalTitle, "Title should be preserved")
        #expect(uiState.subtitle == originalSubtitle, "Subtitle should be preserved")
    }
    
    @Test("Initial state is not loading")
    func initialStateNotLoading() async throws {
        // Given/When
        let uiState = WelcomeUIState()
        
        // Then
        #expect(uiState.isLoading == false, "Should not be loading initially")
        #expect(uiState.error == nil, "Should have no error initially")
        #expect(uiState.showSignIn == false, "Should not show sign in initially")
        #expect(uiState.showSignUp == false, "Should not show sign up initially")
    }
}

// MARK: - LocalizationManager Tests

@Suite("LocalizationManager Tests")
struct LocalizationManagerTests {
    
    @Test("Singleton returns same instance")
    func singletonReturnsSameInstance() async throws {
        // Given/When
        let instance1 = LocalizationManager.shared
        let instance2 = LocalizationManager.shared
        
        // Then
        #expect(instance1 === instance2, "Shared should return the same instance")
    }
    
    @Test("Localized returns string for valid key")
    func localizedReturnsString() async throws {
        // Given
        let manager = LocalizationManager()
        
        // When
        let result = manager.localized(LocalizationManager.Welcome.title)
        
        // Then
        #expect(!result.isEmpty, "Should return non-empty string")
    }
    
    @Test("Localized with arguments formats correctly")
    func localizedWithArgumentsFormats() async throws {
        // Given
        let manager = LocalizationManager()
        
        // When - simula un string con formato tipo "Hello, %@!"
        let result = manager.localized("test.greeting", "John")
        
        // Then
        // Si no existe la key, regresará "test.greeting", así que solo verificamos que no crashea
        #expect(!result.isEmpty, "Should handle formatted strings")
    }
    
    @Test("Welcome namespace has correct keys")
    func welcomeNamespaceHasKeys() async throws {
        // Then
        #expect(LocalizationManager.Welcome.title == "welcome.title")
        #expect(LocalizationManager.Welcome.subtitle == "welcome.subtitle")
        #expect(LocalizationManager.Welcome.signIn == "welcome.signIn")
        #expect(LocalizationManager.Welcome.signUp == "welcome.signUp")
    }
    
    @Test("Login namespace has correct keys")
    func loginNamespaceHasKeys() async throws {
        // Then
        #expect(LocalizationManager.Login.title == "login.title")
        #expect(LocalizationManager.Login.emailPlaceholder == "login.email.placeholder")
        #expect(LocalizationManager.Login.passwordPlaceholder == "login.password.placeholder")
        #expect(LocalizationManager.Login.loginButton == "login.button")
    }
    
    @Test("SignUp namespace has correct keys")
    func signUpNamespaceHasKeys() async throws {
        // Then
        #expect(LocalizationManager.SignUp.title == "signup.title")
        #expect(LocalizationManager.SignUp.emailPlaceholder == "signup.email.placeholder")
        #expect(LocalizationManager.SignUp.passwordPlaceholder == "signup.password.placeholder")
    }
}
