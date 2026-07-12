import SwiftUI

/// Atom: rounded surface container.
///
/// Overview: The DSCard struct creates a rounded corner container that automatically adjusts to light and dark mode using the system's material background.
/// - Parameters:
///   - content: A view builder closure that specifies the content to be displayed within the card.
/// - Returns: A new instance of `DSCard`.
///
/// Example Usage:
///
/// ```swift
/// DSCard {
///     Text("Hello, DSCard!")
///         .padding()
/// }
/// ```
//
public struct DSCard<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        DSGlassSurface {
            content
                .padding(DSSpacing.lg)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
