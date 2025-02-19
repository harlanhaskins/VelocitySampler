// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "VelocitySampler",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "VelocitySampler",
            targets: ["VelocitySampler"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-collections", from: "1.1.4")
    ],
    targets: [
        .target(
            name: "VelocitySampler",
            dependencies: [
                .product(name: "Collections", package: "swift-collections")
            ]
        ),
        .testTarget(
            name: "VelocitySamplerTests",
            dependencies: ["VelocitySampler"]
        ),
    ]
)
