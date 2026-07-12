import SwiftUI

/// Background principal con animaciones sutiles en tonos azules.
/// Diseñado para aplicaciones SSH/OpenClaw con estética técnica moderna.
public struct Background<Content: View>: View {
    @Environment(\.jacksshTheme) var theme
    @Environment(\.colorScheme) var colorScheme
    private let content: () -> Content
    private let showGrid: Bool
    
    @State private var phase1: CGFloat = 0
    @State private var phase2: CGFloat = 0
    @State private var phase3: CGFloat = 0
    
    public init(showGrid: Bool = false, @ViewBuilder content: @escaping () -> Content) {
        self.showGrid = showGrid
        self.content = content
    }

    public var body: some View {
        ZStack {
            // Color base
            theme.colors.background
                .ignoresSafeArea()
            
            // Gradientes animados en AZUL
            GeometryReader { geo in
                ZStack {
                    // Gradiente base oscuro a claro
                    LinearGradient(
                        colors: [
                            theme.colors.background,
                            theme.colors.background.opacity(0.95),
                            Color.blue.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    // Orbe azul claro 1 (movimiento horizontal + vertical)
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.blue.opacity(colorScheme == .dark ? 0.3 : 0.15),
                                    Color.blue.opacity(colorScheme == .dark ? 0.15 : 0.08),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 200
                            )
                        )
                        .frame(width: 400, height: 400)
                        .offset(
                            x: geo.size.width * (0.2 + phase1 * 0.6) - 200,
                            y: geo.size.height * (0.3 + sin(phase1 * .pi * 2) * 0.3) - 200
                        )
                        .blur(radius: 80)
                        .blendMode(.screen)
                    
                    // Orbe azul oscuro 2 (movimiento contrario)
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(red: 0.2, green: 0.4, blue: 0.8).opacity(colorScheme == .dark ? 0.25 : 0.12),
                                    Color(red: 0.1, green: 0.3, blue: 0.7).opacity(colorScheme == .dark ? 0.12 : 0.06),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 180
                            )
                        )
                        .frame(width: 360, height: 360)
                        .offset(
                            x: geo.size.width * (0.8 - phase2 * 0.5) - 180,
                            y: geo.size.height * (0.7 + cos(phase2 * .pi * 2) * 0.25) - 180
                        )
                        .blur(radius: 70)
                        .blendMode(.screen)
                    
                    // Orbe azul medio 3 (movimiento circular)
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(red: 0.3, green: 0.5, blue: 0.9).opacity(colorScheme == .dark ? 0.2 : 0.1),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 150
                            )
                        )
                        .frame(width: 300, height: 300)
                        .offset(
                            x: geo.size.width * (0.5 + sin(phase3 * .pi * 2) * 0.3) - 150,
                            y: geo.size.height * (0.5 + cos(phase3 * .pi * 2) * 0.3) - 150
                        )
                        .blur(radius: 60)
                        .blendMode(.screen)
                }
            }
            .ignoresSafeArea()
            
            // Grid opcional
            if showGrid {
                TerminalGridPattern()
                    .opacity(colorScheme == .dark ? 0.03 : 0.02)
                    .blendMode(.overlay)
                    .ignoresSafeArea()
            }

            content()
        }
        .onAppear {
            // Animación del orbe 1 (lento)
            withAnimation(
                .linear(duration: 25)
                .repeatForever(autoreverses: false)
            ) {
                phase1 = 1
            }
            
            // Animación del orbe 2 (medio)
            withAnimation(
                .linear(duration: 20)
                .repeatForever(autoreverses: false)
            ) {
                phase2 = 1
            }
            
            // Animación del orbe 3 (rápido)
            withAnimation(
                .linear(duration: 15)
                .repeatForever(autoreverses: false)
            ) {
                phase3 = 1
            }
        }
    }
}

// MARK: - Terminal Grid Pattern

private struct TerminalGridPattern: View {
    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                let cellWidth: CGFloat = 10
                let cellHeight: CGFloat = 18
                
                var x: CGFloat = 0
                while x < size.width {
                    context.stroke(
                        Path { path in
                            path.move(to: CGPoint(x: x, y: 0))
                            path.addLine(to: CGPoint(x: x, y: size.height))
                        },
                        with: .color(.white.opacity(0.1)),
                        lineWidth: 0.3
                    )
                    x += cellWidth
                }
                
                var y: CGFloat = 0
                while y < size.height {
                    context.stroke(
                        Path { path in
                            path.move(to: CGPoint(x: 0, y: y))
                            path.addLine(to: CGPoint(x: size.width, y: y))
                        },
                        with: .color(.white.opacity(0.1)),
                        lineWidth: 0.3
                    )
                    y += cellHeight
                }
            }
        }
    }
}

// MARK: - BackgroundElevated

public struct BackgroundElevated<Content: View>: View {
    @Environment(\.jacksshTheme) var theme
    @Environment(\.colorScheme) var colorScheme
    private let content: () -> Content
    private let cornerRadius: CGFloat
    private let useLiquidGlass: Bool
    
    public init(
        cornerRadius: CGFloat = 12,
        useLiquidGlass: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.useLiquidGlass = useLiquidGlass
        self.content = content
    }

    public var body: some View {
        if useLiquidGlass {
            content()
                .padding(DSSpacing.md)
                .background {
                    ZStack {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(.ultraThinMaterial)
                        
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        theme.colors.surfaceElevated.opacity(0.2),
                                        theme.colors.surfaceElevated.opacity(0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(colorScheme == .dark ? 0.2 : 0.4),
                                        .white.opacity(colorScheme == .dark ? 0.05 : 0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    }
                    .shadow(
                        color: .black.opacity(colorScheme == .dark ? 0.5 : 0.1),
                        radius: 20,
                        x: 0,
                        y: 10
                    )
                }
        } else {
            content()
                .padding(DSSpacing.md)
                .background {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(theme.colors.surfaceElevated)
                }
        }
    }
}
