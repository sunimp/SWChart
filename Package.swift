// swift-tools-version:5.10

import PackageDescription

let package = Package(
    name: "Chart",
    platforms: [
        .iOS(.v14),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "Chart",
            targets: ["Chart"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/SnapKit/SnapKit.git", .upToNextMajor(from: "5.0.1")),
        .package(url: "https://github.com/sunimp/UIExtensions.Swift.git", .upToNextMajor(from: "1.2.0")),
        .package(url: "https://github.com/sunimp/WWExtensions.Swift.git", .upToNextMajor(from: "1.1.0")),
        .package(url: "https://github.com/nicklockwood/SwiftFormat.git", from: "0.54.0"),
    ],
    targets: [
        .target(
            name: "Chart",
            dependencies: [
                "SnapKit",
                .product(name: "UIExtensions", package: "UIExtensions.Swift"),
                .product(name: "WWExtensions", package: "WWExtensions.Swift"),
            ]
        ),
    ]
)
