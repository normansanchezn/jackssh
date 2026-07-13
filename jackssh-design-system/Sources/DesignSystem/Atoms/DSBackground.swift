import SwiftUI

/// Dark operational background used by JackSSH console screens.
public struct DSBackground<Content: View>: View {
    @Environment(\.jacksshTheme) var theme
    private let content: () -> Content
    private let showGrid: Bool
    
    public init(showGrid: Bool = false, @ViewBuilder content: @escaping () -> Content) {
        self.showGrid = showGrid
        self.content = content
    }

    public var body: some View {
        ZStack {
            theme.colors.background
                .ignoresSafeArea(.container)

            LinearGradient(
                colors: [
                    theme.colors.primary100.opacity(0.20),
                    theme.colors.background.opacity(0.20),
                    theme.colors.background
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea(.container)

            if showGrid {
                Canvas { context, size in
                    let cellWidth: CGFloat = 12
                    let cellHeight: CGFloat = 18
                    
                    var x: CGFloat = 0
                    while x < size.width {
                        context.stroke(
                            Path { path in
                                path.move(to: CGPoint(x: x, y: 0))
                                path.addLine(to: CGPoint(x: x, y: size.height))
                            },
                            with: .color(theme.colors.border.opacity(0.45)),
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
                            with: .color(theme.colors.border.opacity(0.38)),
                            lineWidth: 0.3
                        )
                        y += cellHeight
                    }
                }
                .opacity(0.45)
                .blendMode(.overlay)
                .ignoresSafeArea(.container)
            }

            content()
        }
    }
}

public struct DSBackgroundElevated<Content: View>: View {
    @Environment(\.jacksshTheme) var theme
    @Environment(\.colorScheme) var colorScheme
    private let content: () -> Content
    private let cornerRadius: CGFloat
    
    public init(
        cornerRadius: CGFloat = 12,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.content = content
    }

    public var body: some View {
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
    }
}
