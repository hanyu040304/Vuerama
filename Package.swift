// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "VueramaCore",
    platforms: [
        .macOS(.v27)
    ],
    products: [
        .library(name: "VueramaCore", targets: ["VueramaCore"])
    ],
    targets: [
        .target(name: "VueramaCore"),
        .testTarget(
            name: "VueramaCoreTests",
            dependencies: ["VueramaCore"]
        )
    ]
)
