// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "Clipper",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "Clipper", targets: ["Clipper"])
    ],
    dependencies: [
        .package(url: "https://github.com/sindresorhus/KeyboardShortcuts", from: "2.0.0")
    ],
    targets: [
        .executableTarget(
            name: "Clipper",
            dependencies: ["KeyboardShortcuts"],
            exclude: ["Info.plist"]
        ),
        .testTarget(
            name: "ClipperTests",
            dependencies: ["Clipper"]
        ),
    ]
)
