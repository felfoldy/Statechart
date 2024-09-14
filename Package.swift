// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StateGraph",
    platforms: [.macOS(.v14), .iOS(.v17), .watchOS(.v10), .tvOS(.v17)],
    products: [
        .library(name: "StateGraph", targets: ["StateGraph"]),
    ],
    dependencies: [
        .package(url: "https://github.com/felfoldy/LogTools.git", from: "1.0.1"),
    ],
    targets: [
        .target(name: "StateGraph", dependencies: ["LogTools"]),
        .testTarget(
            name: "StateGraphTests",
            dependencies: ["StateGraph"]
        ),
    ]
)
