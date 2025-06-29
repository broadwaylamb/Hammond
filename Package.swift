// swift-tools-version:6.0

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "Hammond",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
        .macCatalyst(.v13),
    ],
    products: [
        .library(name: "Hammond", targets: ["Hammond"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax", from: "601.0.1"),
    ],
    targets: [
        .target(
            name: "Hammond",
            dependencies: ["HammondMacros"]
        ),
        .macro(
            name: "HammondMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ],
        ),
        .testTarget(
            name: "HammondMacrosTests",
            dependencies: [
                "HammondMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ],
        )
    ],
    swiftLanguageModes: [.v5, .v6]
)
