// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "jackssh-presentation",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "jackssh-presentation",
            targets: ["jackssh-presentation"]
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "jackssh-presentation"
        ),
        .testTarget(
            name: "jackssh-presentationTests",
            dependencies: ["jackssh-presentation"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
