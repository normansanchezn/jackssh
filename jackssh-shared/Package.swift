// swift-tools-version: 6.3
import PackageDescription

// Shared: truly reusable cross-cutting utilities only. No feature logic.
let package = Package(
    name: "jackssh-shared",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "Shared", targets: ["Shared"]),
    ],
    targets: [
        .target(name: "Shared"),
        .testTarget(name: "SharedTests", dependencies: ["Shared"]),
    ],
    swiftLanguageModes: [.v6]
)
