// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "OKLCHGradient",
    platforms: [.iOS(.v17), .macOS(.v14), .tvOS(.v17), .visionOS(.v1)],
    products: [.library(name: "OKLCHGradient", targets: ["OKLCHGradient"])],
    targets: [
        .target(
            name: "OKLCHGradient",
            resources: [.process("OKLCHGradient.metal")]
        )
    ]
)
