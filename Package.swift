// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "Hammond",
    products: [
        .library(name: "Hammond", targets: ["Hammond"]),
    ],
    targets: [
        .target(name: "Hammond")
    ]
)
