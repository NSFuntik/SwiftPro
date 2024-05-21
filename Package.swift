// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftPro",
    platforms: [
        .iOS(.v15), .macOS(.v14), .tvOS(.v15), .watchOS(.v8), .macCatalyst(.v15)
    ],
    products: [
        .library(
            name: "SwiftPro", /*type: .dynamic,*/
            targets: ["SwiftPro"]),
    ],
    dependencies: [
        .package(url: "https://github.com/hmlongco/Factory.git", branch: "main"),
    ],
    
    
    targets: [
        .target(
            name: "SwiftPro",
            dependencies: [
                .product(name: "Factory", package: "factory")
            ],
            resources: [
                .process("Resources/Media.xcassets"),
            ]
//            , swiftSettings: [ .unsafeFlags(["-enable-library-evolution"]) ]
        )
    ]
)
