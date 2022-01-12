// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "spi-package-importer",
    platforms: [
        .macOS(.v12)
    ],
    dependencies: [
        .package(name: "swift-argument-parser",
                 url: "https://github.com/apple/swift-argument-parser",
                 from: "1.0.0")
    ],
    targets: [
        .executableTarget(
            name: "importer",
            dependencies: ["ImporterCore"]),
        .target(
            name: "ImporterCore",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]),
        .testTarget(
            name: "ImporterCoreTests",
            dependencies: ["importer"]),
    ]
)
