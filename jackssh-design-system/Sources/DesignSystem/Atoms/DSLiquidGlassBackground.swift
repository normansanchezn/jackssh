//
//  DSLiquidGlassBackground.swift
//  jackssh-design-system
//
//  Created by Norman Sánchez on 12/07/26.
//

import SwiftUI

public struct DSLiquidGlassBackground<Content: View>: View {
    @State private var start = UnitPoint(x: 0, y: -0.5)
    @State private var end = UnitPoint(x: 4, y: 0)
    private let content: Content
    
    // Paleta de colores ajustada: Azul medianoche y negro profundo
    private let colors = [
        Color(red: 0.0, green: 0.0, blue: 0.05),
        Color(red: 0.0, green: 0.02, blue: 0.15),
        Color(red: 0.0, green: 0.0, blue: 0.05)
    ]
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        ZStack {
            // Fondo base oscuro
            Color(.black)
                .ignoresSafeArea()
            
            // Degradado animado sutil
            LinearGradient(gradient: Gradient(colors: colors), startPoint: start, endPoint: end)
                .animation(Animation.easeInOut(duration: 20).repeatForever(autoreverses: true), value: start)
                .ignoresSafeArea()
            
            // Efecto Glass
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(
                    // Burbujas de luz muy tenues para dar sensación de profundidad
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.1))
                            .blur(radius: 100)
                            .offset(x: -50, y: -100)
                        
                        Circle()
                            .fill(Color(red: 0.0, green: 0.1, blue: 0.3).opacity(0.08))
                            .blur(radius: 80)
                            .offset(x: 100, y: 150)
                    }
                )
                .ignoresSafeArea()
            
            // Contenido sobre el cristal
            content
        }
        .onAppear {
            self.start = UnitPoint(x: 4, y: 0)
            self.end = UnitPoint(x: 0, y: 2)
        }
    }
}

#Preview {
    DSLiquidGlassBackground {
        Text("JackSSH Terminal")
            .font(.headline)
            .foregroundColor(.white.opacity(0.9))
    }
}
