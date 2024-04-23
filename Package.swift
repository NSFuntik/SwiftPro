// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftUIPlus",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "SwiftUIPlus",
            targets: ["SwiftUIPlus", ]
        ),
    ],
    dependencies: [
        .package(url:"https://github.com/apple/swift-collections.git",
                 .upToNextMajor(from: "1.1.0")),
        .package(url: "https://github.com/shaps80/SwiftUIBackports", from: "2.8.0"),
        .package(url: "https://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@github.com/NSFuntik/SFSymbolEnum", branch: "main")
        
    ],
    
    
    targets: [
        .target(
            name: "SwiftUIPlus",
            dependencies: [
                "SwiftUIBackports",
                .product(name: "OrderedCollections", package: "swift-collections"),
                .product(name: "SFSymbolEnum", package: "SFSymbolEnum")
            ],
            resources: [
                .embedInCode("Resources/bg.jpg"),
                .process("Resources/Media.xcassets"),
                .process("Resources/bg.jpg"),

                
                //                .process("Resources/Permissions.plist")
            ])
    ]
)
