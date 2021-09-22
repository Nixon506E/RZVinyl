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
            name: "RZExtensions",
            targets: ["RZExtensions"]),
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
            path: "Classes"),
        .target(
            name: "RZExtensions",
            dependencies: ["RZVinyl","RZImport"],
            path: "Extensions"),
    ]
)
