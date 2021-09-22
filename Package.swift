// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "RZVinyl",
    platforms: [
        .iOS(.v8),
    ],
    products: [
        .library(
            name: "RZVinylCore",
            targets: ["RZVinylCore"]),
        .library(
            name: "RZVinylExtensions",
            targets: ["RZVinylExtensions"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/Nixon506E/RZImport.git", 
            from: "2.0.0"
        )
    ],
    targets: [
        .target(
            name: "Core",
            path: "Classes"),
        .target(
            name: "Extensions",
            dependencies: ["Core","RZImport"],
            path: "Extensions"),
    ]
)
