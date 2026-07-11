// swift-tools-version: 6.3
import PackageDescription

// DesignSystem: reusable SwiftUI visual components only (Atomic Design). No feature logic.
let package = Package(
    name: "jackssh-design-system",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "DesignSystem", targets: ["DesignSystem"]),
    ],
    targets: [
        .target(name: "DesignSystem"),
        .testTarget(name: "DesignSystemTests", dependencies: ["DesignSystem"]),
    ],
    swiftLanguageModes: [.v6]
)
