import SwiftUI

/// Componente de botón del Design System con tres estilos: Filled, Outline, y Text.
/// Diseñado específicamente para aplicaciones SSH/OpenClaw con estética técnica y Liquid Glass.
public struct DSButton: View {
    @Environment(\.jacksshTheme) var theme
    @Environment(\.isEnabled) private var isEnabled
    
    private let title: String
    private let icon: String?
    private let style: DSButtonStyle
    private let size: DSButtonSize
    private let fullWidth: Bool
    private let isLoading: Bool
    private let action: () -> Void
    
    /// Crea un botón del Design System con efectos Liquid Glass
    /// - Parameters:
    ///   - title: Texto del botón
    ///   - icon: Nombre del SF Symbol opcional (aparece antes del texto)
    ///   - style: Estilo visual del botón (.filled, .outline, .text)
    ///   - size: Tamaño del botón (.small, .medium, .large)
    ///   - fullWidth: Si debe ocupar todo el ancho disponible
    ///   - isLoading: Muestra un indicador de progreso en lugar del contenido
    ///   - action: Acción a ejecutar al presionar el botón
    public init(
        _ title: String,
        icon: String? = nil,
        style: DSButtonStyle = .filled,
        size: DSButtonSize = .medium,
        fullWidth: Bool = false,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.size = size
        self.fullWidth = fullWidth
        self.isLoading = isLoading
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            buttonContent
                .padding(.horizontal, size.horizontalPadding)
                .padding(.vertical, size.verticalPadding)
                .frame(maxWidth: fullWidth ? .infinity : nil)
                .background(backgroundView)
                .opacity(isEnabled ? 1.0 : 0.6)
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
    }
    
    // MARK: - Content
    
    private var buttonContent: some View {
        HStack(spacing: DSSpacing.sm) {
            if isLoading {
                ProgressView()
                    .tint(textColor)
                    .controlSize(size.progressControlSize)
            } else {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(size.iconFont)
                }
                
                Text(title)
                    .font(size.font)
                    .fontWeight(size.fontWeight)
            }
        }
        .foregroundStyle(textColor)
    }
    
    // MARK: - Background with Liquid Glass
    
    @ViewBuilder
    private var backgroundView: some View {
        switch style {
        case .filled:
            // Filled: Usa Liquid Glass con tinte y efecto interactivo
            ZStack {
                RoundedRectangle(cornerRadius: size.cornerRadius)
                    .fill(theme.colors.primary600)
                
                // Overlay con efecto de vidrio para profundidad
                RoundedRectangle(cornerRadius: size.cornerRadius)
                    .fill(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.3),
                                .clear,
                                .black.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .blendMode(.overlay)
            }
            .shadow(color: theme.colors.primary600.opacity(0.3), radius: 8, x: 0, y: 4)
            
        case .outline:
            // Outline: Borde con efecto de vidrio translúcido
            ZStack {
                // Fondo con desenfoque sutil
                RoundedRectangle(cornerRadius: size.cornerRadius)
                    .fill(.ultraThinMaterial)
                    .opacity(0.5)
                
                // Borde con gradiente
                RoundedRectangle(cornerRadius: size.cornerRadius)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                theme.colors.primary600,
                                theme.colors.primary500.opacity(0.6)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
                
                // Brillo sutil en el borde superior
                RoundedRectangle(cornerRadius: size.cornerRadius)
                    .fill(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.2),
                                .clear
                            ],
                            startPoint: .top,
                            endPoint: .center
                        )
                    )
                    .blendMode(.overlay)
            }
            
        case .text:
            // Text: Sin fondo, solo efecto hover sutil
            RoundedRectangle(cornerRadius: size.cornerRadius)
                .fill(.clear)
        }
    }
    
    // MARK: - Computed Properties
    
    private var textColor: Color {
        guard isEnabled else {
            return theme.colors.textTertiary
        }
        
        switch style {
        case .filled:
            return theme.colors.textInverse
        case .outline:
            return theme.colors.primary600
        case .text:
            return theme.colors.primary600
        }
    }
}

// MARK: - Button Style Enum

/// Estilos visuales disponibles para DSButton
public enum DSButtonStyle {
    /// Botón relleno con color primario (acción principal)
    case filled
    
    /// Botón con borde y texto en color primario (acción secundaria)
    case outline
    
    /// Botón solo con texto, sin borde ni relleno (acción terciaria)
    case text
}

// MARK: - Button Size Enum

/// Tamaños disponibles para DSButton
public enum DSButtonSize {
    case small
    case medium
    case large
    
    var font: Font {
        switch self {
        case .small:
            return .system(.footnote, weight: .medium)
        case .medium:
            return .system(.body, weight: .semibold)
        case .large:
            return .system(.title3, weight: .bold)
        }
    }
    
    var iconFont: Font {
        switch self {
        case .small:
            return .system(.footnote)
        case .medium:
            return .system(.body)
        case .large:
            return .system(.title3)
        }
    }
    
    var fontWeight: Font.Weight {
        switch self {
        case .small:
            return .medium
        case .medium:
            return .semibold
        case .large:
            return .bold
        }
    }
    
    var horizontalPadding: CGFloat {
        switch self {
        case .small:
            return DSSpacing.md
        case .medium:
            return DSSpacing.lg
        case .large:
            return DSSpacing.xl
        }
    }
    
    var verticalPadding: CGFloat {
        switch self {
        case .small:
            return DSSpacing.sm
        case .medium:
            return DSSpacing.md
        case .large:
            return DSSpacing.lg
        }
    }
    
    var cornerRadius: CGFloat {
        switch self {
        case .small:
            return DSRadius.sm
        case .medium:
            return DSRadius.md
        case .large:
            return DSRadius.lg
        }
    }
    
    var progressControlSize: ControlSize {
        switch self {
        case .small:
            return .mini
        case .medium:
            return .regular
        case .large:
            return .large
        }
    }
}

// MARK: - Preview

#Preview("Liquid Glass Buttons") {
    ScrollView {
        VStack(spacing: DSSpacing.xl) {
            // Header
            VStack(spacing: DSSpacing.sm) {
                Image(systemName: "sparkles")
                    .font(.system(size: 40))
                    .foregroundStyle(.blue)
                
                Text("Liquid Glass Design")
                    .font(.title2.bold())
                
                Text("Modern translucent materials")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, DSSpacing.lg)
            
            Divider()
            
            // Filled Style
            VStack(alignment: .leading, spacing: DSSpacing.md) {
                Text("Filled Style")
                    .font(.headline)
                Text("Solid background with gradient overlay")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                DSButton("Primary Action", icon: "arrow.right", style: .filled) {
                    print("Filled tapped")
                }
                
                DSButton("Connect SSH", icon: "terminal", style: .filled, fullWidth: true) {
                    print("Full width filled")
                }
            }
            .padding(.horizontal)
            
            Divider()
            
            // Outline Style with Liquid Glass
            VStack(alignment: .leading, spacing: DSSpacing.md) {
                Text("Outline Style")
                    .font(.headline)
                Text("Ultra-thin material with gradient border")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                DSButton("Secondary Action", icon: "gear", style: .outline) {
                    print("Outline tapped")
                }
                
                DSButton("Configure Host", icon: "slider.horizontal.3", style: .outline, fullWidth: true) {
                    print("Full width outline")
                }
            }
            .padding(.horizontal)
            
            Divider()
            
            // Text Style
            VStack(alignment: .leading, spacing: DSSpacing.md) {
                Text("Text Style")
                    .font(.headline)
                Text("Minimal appearance for tertiary actions")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                DSButton("Cancel", style: .text) {
                    print("Text tapped")
                }
                
                DSButton("Learn More", icon: "info.circle", style: .text) {
                    print("Text with icon")
                }
            }
            .padding(.horizontal)
            
            Divider()
            
            // Loading States
            VStack(alignment: .leading, spacing: DSSpacing.md) {
                Text("Loading States")
                    .font(.headline)
                
                HStack(spacing: DSSpacing.md) {
                    DSButton("Loading", style: .filled, isLoading: true) {}
                    DSButton("Loading", style: .outline, isLoading: true) {}
                    DSButton("Loading", style: .text, isLoading: true) {}
                }
            }
            .padding(.horizontal)
            
            Divider()
            
            // Sizes
            VStack(alignment: .leading, spacing: DSSpacing.md) {
                Text("Sizes")
                    .font(.headline)
                
                DSButton("Small Button", size: .small, fullWidth: true) {}
                DSButton("Medium Button", size: .medium, fullWidth: true) {}
                DSButton("Large Button", size: .large, fullWidth: true) {}
            }
            .padding(.horizontal)
            
            Divider()
            
            // Disabled States
            VStack(alignment: .leading, spacing: DSSpacing.md) {
                Text("Disabled States")
                    .font(.headline)
                
                DSButton("Disabled Filled", style: .filled, fullWidth: true) {}
                    .disabled(true)
                
                DSButton("Disabled Outline", style: .outline, fullWidth: true) {}
                    .disabled(true)
                
                DSButton("Disabled Text", style: .text, fullWidth: true) {}
                    .disabled(true)
            }
            .padding(.horizontal)
            
            Spacer(minLength: DSSpacing.xl)
        }
    }
    .background(
        LinearGradient(
            colors: [
                Color(red: 0.1, green: 0.1, blue: 0.15),
                Color(red: 0.15, green: 0.1, blue: 0.2)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    )
}

#Preview("SSH App with Liquid Glass") {
    ScrollView {
        VStack(spacing: DSSpacing.xl) {
            // Hero Section
            VStack(spacing: DSSpacing.md) {
                Image(systemName: "terminal.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.blue)
                    .shadow(color: .blue.opacity(0.5), radius: 20)
                
                Text("JackSSH")
                    .font(.largeTitle.bold())
                
                Text("Modern SSH Client")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, DSSpacing.xl)
            
            // Login Form Card
            VStack(spacing: DSSpacing.lg) {
                Text("Welcome Back")
                    .font(.title2.bold())
                
                VStack(spacing: DSSpacing.md) {
                    // Email field
                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundStyle(.secondary)
                        Text("email@example.com")
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    
                    // Password field
                    HStack {
                        Image(systemName: "lock.fill")
                            .foregroundStyle(.secondary)
                        Text("••••••••")
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                }
                
                // Action Buttons
                VStack(spacing: DSSpacing.md) {
                    DSButton(
                        "Sign In",
                        icon: "arrow.right.circle.fill",
                        style: .filled,
                        fullWidth: true
                    ) {
                        print("Sign in")
                    }
                    
                    DSButton(
                        "Create Account",
                        icon: "person.badge.plus",
                        style: .outline,
                        fullWidth: true
                    ) {
                        print("Sign up")
                    }
                    
                    DSButton(
                        "Forgot Password?",
                        style: .text
                    ) {
                        print("Forgot password")
                    }
                }
            }
            .padding(DSSpacing.xl)
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.3), radius: 30)
            }
            .padding(.horizontal, DSSpacing.lg)
            
            Divider()
                .padding(.vertical)
            
            // SSH Actions Card
            VStack(spacing: DSSpacing.lg) {
                Text("Quick Actions")
                    .font(.headline)
                
                HStack(spacing: DSSpacing.md) {
                    DSButton(
                        "Connect",
                        icon: "terminal",
                        style: .filled
                    ) {
                        print("Connect")
                    }
                    
                    DSButton(
                        "Settings",
                        icon: "gear",
                        style: .outline
                    ) {
                        print("Settings")
                    }
                    
                    DSButton(
                        "Info",
                        icon: "info.circle",
                        style: .text
                    ) {
                        print("Info")
                    }
                }
                
                // Host List
                VStack(spacing: DSSpacing.sm) {
                    ForEach(0..<3) { index in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Server \(index + 1)")
                                    .font(.subheadline.bold())
                                Text("192.168.1.10\(index)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            DSButton(
                                "Connect",
                                icon: "play.fill",
                                style: .filled,
                                size: .small
                            ) {
                                print("Connect to server \(index)")
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                    }
                }
            }
            .padding(DSSpacing.xl)
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.3), radius: 30)
            }
            .padding(.horizontal, DSSpacing.lg)
            
            Spacer(minLength: DSSpacing.xl)
        }
    }
    .background(
        ZStack {
            // Base gradient
            LinearGradient(
                colors: [
                    Color(red: 0.08, green: 0.1, blue: 0.15),
                    Color(red: 0.12, green: 0.08, blue: 0.18),
                    Color(red: 0.1, green: 0.12, blue: 0.2)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Ambient glow
            RadialGradient(
                colors: [
                    Color.blue.opacity(0.15),
                    Color.clear
                ],
                center: .topLeading,
                startRadius: 0,
                endRadius: 400
            )
            
            RadialGradient(
                colors: [
                    Color.purple.opacity(0.1),
                    Color.clear
                ],
                center: .bottomTrailing,
                startRadius: 0,
                endRadius: 300
            )
        }
        .ignoresSafeArea()
    )
}
