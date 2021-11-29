// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "Chart",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "Chart",
            targets: ["Chart"]),
    ],
    dependencies: [
        .package(url: "https://github.com/horizontalsystems/UIExtensions.git", .upToNextMajor(from: "1.1.1")),
        .package(url: "https://github.com/SnapKit/SnapKit.git", .upToNextMajor(from: "5.0.1")),
    ],
    targets: [
        .target(
            name: "Chart",
            dependencies: ["UIExtensions", "SnapKit"]),
    ]
)
