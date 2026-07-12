//
//  WelcomeViewModel.swift
//  jackssh-presentation
//
//  Created by Norman Sánchez on 12/07/26.
//

import Foundation
import Combine
import SwiftUI

/// ViewModel para la pantalla de Welcome
/// Maneja la lógica de negocio y coordina entre el estado y los efectos
@MainActor
public final class WelcomeViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published public private(set) var uiState: WelcomeUIState
    @Published public private(set) var effect: WelcomeEffect = .none
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Dependencies (inyecta aquí tus casos de uso/repositorios)
    // private let authUseCase: AuthUseCaseProtocol
    
    // MARK: - Initialization
    public init(uiState: WelcomeUIState = WelcomeUIState()) {
        self.uiState = uiState
    }
    
    // MARK: - Public Methods (Actions/Intents)
    
    /// Maneja el tap en el botón de Sign In
    public func onSignInTapped() {
        uiState.isLoading = true
        
        // Simula navegación o lógica de negocio
        Task {
            // Aquí podrías hacer validaciones previas o llamar a casos de uso
            await performSignInAction()
        }
    }
    
    /// Maneja el tap en el botón de Sign Up
    public func onSignUpTapped() {
        uiState.isLoading = true
        
        Task {
            await performSignUpAction()
        }
    }
    
    /// Limpia el efecto después de ser consumido
    public func clearEffect() {
        effect = .none
    }
    
    // MARK: - Private Methods
    
    private func performSignInAction() async {
        // Simula un pequeño delay (puedes removerlo)
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 segundos
        
        uiState.isLoading = false
        effect = .navigateToSignIn
    }
    
    private func performSignUpAction() async {
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        uiState.isLoading = false
        effect = .navigateToSignUp
    }
    
    /// Maneja errores de manera centralizada
    private func handleError(_ error: Error) {
        uiState.isLoading = false
        uiState.error = error
        effect = .showError(message: error.localizedDescription)
    }
}
