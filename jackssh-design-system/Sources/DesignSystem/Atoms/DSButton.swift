import SwiftUI

/// A modern button component with Liquid Glass design and multiple visual styles.
///
/// `DSButton` provides a consistent, accessible button interface across your app
/// with support for icons, loading states, multiple sizes, and three distinct visual
/// styles: filled, outline, and text-only. The component automatically adapts to
/// the current theme and respects system accessibility settings.
///
/// ## Overview
///
/// Use buttons to enable users to take actions with a single tap. Choose the
/// appropriate style based on the importance of the action:
///
/// - **Filled**: High-emphasis actions (primary buttons)
/// - **Outline**: Medium-emphasis actions (secondary buttons)  
/// - **Text**: Low-emphasis actions (tertiary buttons)
///
/// ## Creating a Button
///
/// Create a simple filled button:
///
/// ```swift
/// DSButton("Sign In", icon: "arrow.right") {
///     performSignIn()
/// }
/// ```
///
/// Create a full-width outline button:
///
/// ```swift
/// DSButton("Create Account", 
///          icon: "person.badge.plus",
///          style: .outline,
///          fullWidth: true) {
///     showRegistration()
/// }
/// ```
///
/// ## Handling Loading States
///
/// Display a loading indicator while processing:
///
/// ```swift
/// DSButton("Connect",
///          icon: "terminal",
///          isLoading: viewModel.isConnecting) {
///     viewModel.connect()
/// }
/// ```
///
/// ## Button Sizes
///
/// Choose from three predefined sizes:
///
/// ```swift
/// DSButton("Small", size: .small) { }
/// DSButton("Medium", size: .medium) { }
/// DSButton("Large", size: .large) { }
/// ```
///
/// ## Accessibility
///
/// `DSButton` automatically:
/// - Scales fonts with Dynamic Type
/// - Provides appropriate contrast ratios
/// - Indicates disabled states with reduced opacity
/// - Prevents interaction when loading
///
/// ## Topics
///
/// ### Creating Buttons
///
/// - ``init(_:icon:style:size:fullWidth:isLoading:action:)``
///
/// ### Button Styles
///
/// - ``DSButtonStyle``
/// - ``DSButtonSize``
///
/// ### Customizing Appearance
///
/// - ``fullWidth``
/// - ``isLoading``
///
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
    
    /// Creates a button with the specified configuration.
    ///
    /// - Parameters:
    ///   - title: The text displayed on the button.
    ///   - icon: An optional SF Symbol name to display before the title.
    ///   - style: The visual style of the button. Defaults to `.filled`.
    ///   - size: The size of the button. Defaults to `.medium`.
    ///   - fullWidth: Whether the button should expand to fill available width. Defaults to `false`.
    ///   - isLoading: Whether to show a loading indicator instead of the button content. Defaults to `false`.
    ///   - action: The closure to execute when the user taps the button.
    ///
    /// ## Example
    ///
    /// ```swift
    /// DSButton("Connect",
    ///          icon: "terminal.fill",
    ///          style: .filled,
    ///          fullWidth: true) {
    ///     print("Connecting...")
    /// }
    /// ```
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
            RoundedRectangle(cornerRadius: size.cornerRadius)
                .fill(theme.colors.primary600)
                .overlay {
                    RoundedRectangle(cornerRadius: size.cornerRadius)
                        .fill(Color.white.opacity(0.08))
                }
        case .outline:
            RoundedRectangle(cornerRadius: size.cornerRadius)
                .fill(.thinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: size.cornerRadius)
                        .strokeBorder(theme.colors.primary600.opacity(0.8), lineWidth: 1)
                }
        case .text:
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

/// The visual style of a button.
///
/// Button styles convey hierarchy and importance in your interface:
///
/// - Use ``filled`` for primary actions that deserve the most emphasis
/// - Use ``outline`` for secondary actions that need less attention
/// - Use ``text`` for tertiary or low-priority actions
///
/// ## Examples
///
/// ```swift
/// // Primary action - filled button
/// DSButton("Sign In", style: .filled) {
///     signIn()
/// }
///
/// // Secondary action - outline button  
/// DSButton("Cancel", style: .outline) {
///     dismiss()
/// }
///
/// // Tertiary action - text button
/// DSButton("Learn More", style: .text) {
///     showHelp()
/// }
/// ```
public enum DSButtonStyle {
    /// A button with a solid background fill and high contrast text.
    ///
    /// Use filled buttons for primary actions that deserve the most emphasis
    /// in your interface, such as "Save", "Sign In", or "Connect".
    case filled
    
    /// A button with a translucent background and colored border.
    ///
    /// Use outline buttons for secondary actions that need less visual weight
    /// than primary actions, such as "Cancel" or "Settings".
    case outline
    
    /// A button with no background, showing only the text and optional icon.
    ///
    /// Use text buttons for tertiary or low-priority actions, such as
    /// "Learn More", "Skip", or auxiliary navigation.
    case text
}

// MARK: - Button Size Enum

/// The size of a button, affecting padding, font size, and overall dimensions.
///
/// Choose a size based on the button's importance and the available space:
///
/// - ``small``: Compact size for toolbars or tight spaces
/// - ``medium``: Standard size for most buttons (default)
/// - ``large``: Prominent size for important actions
///
/// ## Examples
///
/// ```swift
/// DSButton("Small", size: .small) { }
/// DSButton("Medium", size: .medium) { }
/// DSButton("Large", size: .large) { }
/// ```
public enum DSButtonSize {
    /// A small button with compact padding and footnote-sized text.
    ///
    /// Use for toolbars, inline actions, or when space is constrained.
    case small
    
    /// A medium button with standard padding and body-sized text.
    ///
    /// This is the default size and works well for most use cases.
    case medium
    
    /// A large button with generous padding and title-sized text.
    ///
    /// Use for prominent actions or when you need extra emphasis.
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
                    .foregroundStyle(lightColorTokens.primary600)
                
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
                    .foregroundStyle(lightColorTokens.primary600)
                    .shadow(color: lightColorTokens.primary600.opacity(0.5), radius: 20)
                
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
                    lightColorTokens.primary600.opacity(0.15),
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
