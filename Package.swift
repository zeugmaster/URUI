// swift-tools-version:6.0

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
        .package(url: "https://github.com/BlockchainCommons/URKit", from: "15.0.0"),
    ],
    targets: [
        .target(
            name: "URUI",
            dependencies: ["URKit"])
    ]
)
