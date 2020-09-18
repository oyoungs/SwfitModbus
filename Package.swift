// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftModbus",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "CModbus",
            targets: ["CModbus"]),
        .library(
            name: "SwiftModbus",
            targets: ["SwiftModbus"]),
        .executable(
            name: "Example",
            targets: ["Example"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .systemLibrary(
            name: "CModbus",
            pkgConfig: "libmodbus",
            providers: [
                .brew(["libmodbus"]),
                .apt(["libmodbus-dev"])
            ]
        ),
        .target(
            name: "SwiftModbus",
            dependencies: ["CModbus"]),
        .target(
            name: "Example",
            dependencies: ["SwiftModbus"]),
        .testTarget(
            name: "SwiftModbusTests",
            dependencies: ["SwiftModbus"]),
    ]
)
