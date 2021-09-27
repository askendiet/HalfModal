// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "HalfModal",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "HalfModal",
            targets: ["HalfModal"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "HalfModal",
            dependencies: []),
    ]
)