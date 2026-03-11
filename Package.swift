// swift-tools-version: 5.9
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
        )
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .binaryTarget(
            name: "TelegramLoginData",
            url: "https://github.com/anaserkinov/telegram-login-widget/releases/download/v1.0.0-RC3/TelegramLoginData.xcframework.zip",
            checksum: "1b84112adef41950c8677e0e69e5acce676c6617379a4d6e9bf21a604a29bb93"
        ),
        .target(
            name: "TelegramLoginWidget",
            dependencies: ["TelegramLoginData"],
        ),
    ]
)
