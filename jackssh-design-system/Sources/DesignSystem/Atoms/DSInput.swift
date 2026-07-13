import SwiftUI

/// A themed text input field with Liquid Glass styling.
///
/// `DSInput` provides a consistent, accessible input field that automatically
/// adapts to your app's theme. It supports both standard and secure text entry
/// (for passwords) with built-in visual feedback.
///
/// ## Overview
///
/// Use input fields to collect text from users. The component provides:
/// - Automatic theming and color scheme support
/// - Secure entry mode for passwords
/// - Consistent styling with subtle borders
/// - Proper keyboard management
///
/// ## Creating an Input Field
///
/// Standard text input:
///
/// ```swift
/// @State private var username = ""
///
/// DSInput("Username", text: $username)
/// ```
///
/// Secure password input:
///
/// ```swift
/// @State private var password = ""
///
/// DSInput("Password", text: $password, isSecure: true)
/// ```
///
/// Complete form example:
///
/// ```swift
/// Form {
///     DSInput("Email", text: $email)
///     DSInput("Password", text: $password, isSecure: true)
///     
///     DSButton("Sign In", style: .filled) {
///         signIn()
///     }
/// }
/// ```
///
/// ## Styling
///
/// Input fields automatically:
/// - Use theme colors for text and accents
/// - Show focus state with tint color
/// - Adapt to light and dark modes
/// - Provide appropriate contrast
///
/// ## Accessibility
///
/// The component supports:
/// - Dynamic Type for text scaling
/// - VoiceOver with descriptive labels
/// - Secure entry announcements
/// - Keyboard navigation
///
/// ## Topics
///
/// ### Creating Input Fields
///
/// - ``init(_:text:isSecure:)``
///
/// ### Related Components
///
/// - ``DSButton``
/// - ``DSCard``
///
public struct DSInput: View {
    @Environment(\.jacksshTheme) private var theme
    private let label: String
    private let text: Binding<String>
    private let isSecure: Bool

    /// Creates a themed text input field.
    ///
    /// - Parameters:
    ///   - label: The placeholder text displayed when the field is empty.
    ///   - text: A binding to the text value.
    ///   - isSecure: Whether to obscure text entry for passwords. Defaults to `false`.
    ///
    /// ## Example
    ///
    /// ```swift
    /// @State private var email = ""
    ///
    /// DSInput("Email address", text: $email)
    /// ```
    ///
    /// Secure password field:
    ///
    /// ```swift
    /// @State private var password = ""
    ///
    /// DSInput("Password", text: $password, isSecure: true)
    /// ```
    public init(_ label: String, text: Binding<String>, isSecure: Bool = false) {
        self.label = label
        self.text = text
        self.isSecure = isSecure
    }

    public var body: some View {
        Group {
            if isSecure {
                SecureField(label, text: text)
            } else {
                TextField(label, text: text)
            }
        }
        .textFieldStyle(.plain)
        .tint(theme.colors.primary600)
        .padding(DSSpacing.md)
        .background(theme.colors.surfaceElevated.opacity(0.82), in: RoundedRectangle(cornerRadius: DSRadius.sm, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: DSRadius.sm, style: .continuous)
                .stroke(theme.colors.border.opacity(0.9), lineWidth: 1)
        }
    }
}
