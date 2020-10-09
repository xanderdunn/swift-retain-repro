// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MyModelApp",
    platforms: [
       .macOS(.v10_15)
    ],
    products: [
        .library(name: "RetainTroubleshooting", targets: ["RetainTroubleshooting"]),
        .library(name: "MyModelLib", targets: ["MyModelLib"]),
        .executable(name: "MyModelApp", targets: ["MyModelApp"])
    ],
    dependencies: [
        .package(name: "swift-nio",
                 url: "https://github.com/apple/swift-nio",
                 from: "2.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(name: "RetainTroubleshooting"),
        .target(
            name: "MyModelLib",
            dependencies: [
                           "RetainTroubleshooting",
                           .product(name: "NIO", package: "swift-nio")
                          ]
               ),
        .target(
            name: "MyModelApp",
            dependencies: ["MyModelLib"])
    ]
)
