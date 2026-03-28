// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TelegramLoginWidget",
    platforms: [.iOS(.v17)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "TelegramLoginWidget",
            targets: ["TelegramLoginWidget"]
        ),
        .library(
            name: "TelegramLogin",
            targets: ["TelegramLogin"]
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .binaryTarget(
            name: "TelegramLoginData",
            url: "https://github.com/anaserkinov/telegram-login-widget/releases/download/v1.0.0-RC4/TelegramLoginData.xcframework.zip",
            checksum: "bd7c8aed4bb3d16fdab7d8244c3f93e1e1e20364d8e41f818b53d6e7d0fefe01"
        ),
        .target(
            name: "TelegramLoginWidget",
            dependencies: ["TelegramLoginData"],
        ),
        .target(
            name: "TelegramLogin"
        ),
    ]
)
