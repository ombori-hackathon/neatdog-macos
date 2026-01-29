// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "NeatdogClient",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "NeatdogClient",
            path: "Sources"
        ),
    ]
)
