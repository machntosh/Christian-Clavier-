// swift-tools-version:5.9
import PackageDescription

// SharedCore — logique métier pure et testable du clavier FR familier/QC.
// Conçu pour être validé en ligne de commande via `swift test`, sans Xcode
// ni device iOS. L'app et la Keyboard Extension (cibles Xcode) consomment ce
// package. Voir docs/architecture.md.
let package = Package(
    name: "SharedCore",
    platforms: [
        .iOS(.v15),
        .macOS(.v12) // permet `swift test` sur macOS / CI
    ],
    products: [
        .library(name: "SharedCore", targets: ["SharedCore"])
    ],
    targets: [
        .target(
            name: "SharedCore",
            path: "Sources/SharedCore"
        ),
        .testTarget(
            name: "SharedCoreTests",
            dependencies: ["SharedCore"],
            path: "Tests/SharedCoreTests"
        )
    ]
)
