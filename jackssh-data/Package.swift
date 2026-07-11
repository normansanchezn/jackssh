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
    ],
    targets: [
        .target(
            name: "Data",
            dependencies: [
                .product(name: "Domain", package: "jackssh-domain"),
                .product(name: "Shared", package: "jackssh-shared"),
            ]
        ),
        .testTarget(
            name: "DataTests",
            dependencies: ["Data"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
