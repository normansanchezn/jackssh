// swift-tools-version: 6.3
import PackageDescription

// Presentation: SwiftUI views + @Observable view models. Depends on Domain and DesignSystem.
let package = Package(
    name: "jackssh-presentation",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "Presentation", targets: ["Presentation"]),
    ],
    dependencies: [
        .package(path: "../jackssh-domain"),
        .package(path: "../jackssh-design-system"),
        .package(path: "../jackssh-shared"),
    ],
    targets: [
        .target(
            name: "Presentation",
            dependencies: [
                .product(name: "Domain", package: "jackssh-domain"),
                .product(name: "DesignSystem", package: "jackssh-design-system"),
                .product(name: "Shared", package: "jackssh-shared"),
            ]
        ),
        .testTarget(
            name: "PresentationTests",
            dependencies: ["Presentation"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
