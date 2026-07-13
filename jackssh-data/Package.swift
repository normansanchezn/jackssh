// swift-tools-version: 6.3
import PackageDescription

// Data: implements Domain repository protocols. Owns persistence, Keychain, networking adapters.
let package = Package(
    name: "jackssh-data",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "Data", targets: ["Data"]),
    ],
    dependencies: [
        .package(path: "../jackssh-domain"),
        .package(path: "../jackssh-shared"),
        .package(url: "https://github.com/orlandos-nl/Citadel.git", from: "0.12.0"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.81.0"),
    ],
    targets: [
        .target(
            name: "Data",
            dependencies: [
                .product(name: "Domain", package: "jackssh-domain"),
                .product(name: "Shared", package: "jackssh-shared"),
                .product(name: "Citadel", package: "Citadel"),
                .product(name: "NIO", package: "swift-nio"),
            ]
        ),
        .testTarget(
            name: "DataTests",
            dependencies: ["Data"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
