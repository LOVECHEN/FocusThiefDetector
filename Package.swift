// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FocusThiefDetector",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .executableTarget(
            name: "FocusThiefDetector",
            path: "Sources"
        )
    ]
)
