// swift-tools-version: 6.3
import PackageDescription

// Presentation: SwiftUI views + @Observable view models. It depends only on
// Domain contracts/use cases and on UI packages; concrete infrastructure is
// assembled by the application target.
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
        .package(url: "https://github.com/migueldeicaza/SwiftTerm.git", from: "1.2.0"),
    ],
    targets: [
        .target(
            name: "Presentation",
            dependencies: [
                .product(name: "Domain", package: "jackssh-domain"),
                .product(name: "DesignSystem", package: "jackssh-design-system"),
                .product(name: "Shared", package: "jackssh-shared"),
                .product(name: "SwiftTerm", package: "SwiftTerm"),
            ]
        ),
        .testTarget(
            name: "PresentationTests",
            dependencies: ["Presentation"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
