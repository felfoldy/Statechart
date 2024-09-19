// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Statechart",
    platforms: [.macOS(.v14), .iOS(.v17), .watchOS(.v10), .tvOS(.v17)],
    products: [
        .library(name: "Statechart", targets: ["Statechart"]),
    ],
    dependencies: [
        .package(url: "https://github.com/felfoldy/LogTools.git", from: "1.0.1"),
    ],
    targets: [
        .target(name: "Statechart", dependencies: ["LogTools"]),
        .testTarget(
            name: "StatechartTests",
            dependencies: ["Statechart"]
        ),
    ]
)
