import SwiftUI

/// Background principal con efecto Liquid Glass y gradiente sutil.
/// Diseñado para aplicaciones SSH/OpenClaw con una estética técnica moderna.
public struct Background<Content: View>: View {
    @Environment(\.jacksshTheme) var theme
    @Environment(\.colorScheme) var colorScheme
    private let content: () -> Content
    private let showGrid: Bool
    
    /// - Parameters:
    ///   - showGrid: Muestra una sutil cuadrícula de terminal en el fondo (por defecto: false)
    ///   - content: El contenido a mostrar sobre el fondo
    public init(showGrid: Bool = false, @ViewBuilder content: @escaping () -> Content) {
        self.showGrid = showGrid
        self.content = content
    }

    public var body: some View {
        ZStack {
            // Base color
            theme.colors.background
                .ignoresSafeArea()
            
            // Gradiente sutil para profundidad visual
            LinearGradient(
                colors: [
                    theme.colors.background,
                    theme.colors.background.opacity(0.95),
                    colorScheme == .dark 
                        ? theme.colors.neutral200.opacity(0.03)
                        : theme.colors.neutral100.opacity(0.5)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Cuadrícula opcional (muy sutil)
            if showGrid {
                TerminalGridPattern()
                    .opacity(colorScheme == .dark ? 0.02 : 0.015)
                    .blendMode(.overlay)
                    .ignoresSafeArea()
            }

            content()
        }
    }
}

/// Background elevado con efecto Liquid Glass para paneles y tarjetas.
/// Usa .ultraThinMaterial para un efecto de vidrio translúcido moderno.
public struct BackgroundElevated<Content: View>: View {
    @Environment(\.jacksshTheme) var theme
    @Environment(\.colorScheme) var colorScheme
    private let content: () -> Content
    private let cornerRadius: CGFloat
    private let useLiquidGlass: Bool
    
    /// - Parameters:
    ///   - cornerRadius: Radio de las esquinas (por defecto: 12)
    ///   - useLiquidGlass: Usa efecto Liquid Glass (por defecto: true)
    ///   - content: El contenido a mostrar
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
                        // Efecto Liquid Glass con .ultraThinMaterial
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(.ultraThinMaterial)
                        
                        // Gradiente sutil para tinte
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
                        
                        // Borde brillante
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
            // Fallback sin Liquid Glass
            content()
                .padding(DSSpacing.md)
                .background {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(theme.colors.surfaceElevated)
                }
        }
    }
}

/// Patrón de cuadrícula sutil tipo terminal
private struct TerminalGridPattern: View {
    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                let cellWidth: CGFloat = 10
                let cellHeight: CGFloat = 18
                
                // Líneas verticales
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
                
                // Líneas horizontales
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
