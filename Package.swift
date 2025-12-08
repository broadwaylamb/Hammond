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
        .library(name: "HammondMacros", targets: ["HammondMacros"]),
        .library(name: "HammondEncoders", targets: ["HammondEncoders"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax", from: "602.0.0"),
    ],
    targets: [
        .target(
            name: "Hammond",
        ),
        .target(
            name: "HammondEncoders",
            dependencies: ["Hammond"],
        ),
        .target(
            name: "HammondMacros",
            dependencies: ["Hammond", "HammondMacroEngine"],
        ),
        .macro(
            name: "HammondMacroEngine",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ],
        ),
        .testTarget(
            name: "HammondMacrosTests",
            dependencies: [
                "HammondMacroEngine",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ],
        )
    ],
    swiftLanguageModes: [.v5, .v6]
)
