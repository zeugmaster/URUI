// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "URUI",
    platforms: [
        .iOS(.v15),
        .macCatalyst(.v14),
    ],
    products: [
        .library(
            name: "URUI",
            targets: ["URUI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/BlockchainCommons/URKit.git", from: "14.0.0"),
    ],
    targets: [
        .target(
            name: "URUI",
            dependencies: ["URKit"])
    ]
)
