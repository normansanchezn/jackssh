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
    @Published public var title: LocalizedStringKey = "welcome_title"
    @Published public var subtitle: LocalizedStringKey = "welcome_subtitle"
    @Published public var showSignIn: Bool = false
    @Published public var showSignUp: Bool = false
    
    public init() {}
    
    public func reset() {
        isLoading = false
        error = nil
        showSignIn = false
        showSignUp = false
    }
}
