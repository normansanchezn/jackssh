// swift-tools-version: 6.3
import PackageDescription

// Domain: pure business layer. No SwiftUI, UIKit, networking, persistence, SSH, or Keychain.
let package = Package(
    name: "jackssh-domain",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "Domain", targets: ["Domain"]),
    ],
    targets: [
        .target(name: "Domain"),
        .testTarget(name: "DomainTests", dependencies: ["Domain"]),
    ],
    swiftLanguageModes: [.v6]
)
