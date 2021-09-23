// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "RZVinyl",
    platforms: [
        .iOS(.v9),
    ],
    products: [
        .library(
            name: "RZVinyl",
            targets: ["RZVinyl"]),
        .library(
            name: "RZVinyl+Extensions",
            targets: ["RZVinyl+Extensions"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/Nixon506E/RZImport.git", 
            .branch("master")
        )
    ],
    targets: [
        .target(
            name: "RZVinyl",
            publicHeadersPath: "Public"),
        .target(
            name: "RZVinyl+Extensions",
            dependencies: ["RZVinyl","RZImport"],
            publicHeadersPath: "Public"),
    ]
)
