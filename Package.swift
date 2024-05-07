// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftPro",
    platforms: [
        .iOS(.v15), .macOS(.v13), .tvOS(.v15), .watchOS(.v8), .macCatalyst(.v13)
    ],
    products: [
        .library(
            name: "SwiftPro",
            targets: ["SwiftPro", ]
        ),
    ],
    dependencies: [
        .package(url:"https://github.com/apple/swift-collections.git",
                 .upToNextMajor(from: "1.1.0")),
        .package(url: "https://github.com/shaps80/SwiftUIBackports", from: "2.8.0"),
        .package(url: "https://github.com/hmlongco/Factory.git", from: "2.3.2"),

        .package(url: "https://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@github.com/NSFuntik/SFSymbolEnum", branch: "main")
        
    ],
    
    
    targets: [
        .target(
            name: "SwiftPro",
            dependencies: [
                "SwiftUIBackports",
                .product(name: "Factory", package: "factory"),
                .product(name: "OrderedCollections", package: "swift-collections"),
                .product(name: "SFSymbolEnum", package: "SFSymbolEnum")
            ],
            resources: [
                .process("Resources/Media.xcassets"),
            ])
    ]
)
