// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Magpie",
    platforms: [.macOS(.v26)],
    products: [
        .library(name: "MagpieCore", targets: ["MagpieCore"]),
        .executable(name: "Magpie", targets: ["Magpie"]),
    ],
    targets: [
        .target(name: "MagpieCore"),
        .executableTarget(name: "Magpie", dependencies: ["MagpieCore"]),
        .testTarget(name: "MagpieCoreTests", dependencies: ["MagpieCore"]),
        .testTarget(name: "MagpieTests", dependencies: ["Magpie"]),
    ],
    swiftLanguageModes: [.v5]
)
