// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NutriBalance",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "NutriBalance",
            targets: ["NutriBalance"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "NutriBalance",
            dependencies: [],
            path: "NutriBalance",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "NutriBalanceTests",
            dependencies: ["NutriBalance"],
            path: "NutriBalanceTests"
        ),
    ]
)
