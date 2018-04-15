// swift-tools-version:4.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Hammond",
    products: [
        .library(name: "Hammond", type: .static, targets: ["Hammond"]),
    ],
    targets: [
        .target(name: "Hammond", dependencies: [])
    ]
)
