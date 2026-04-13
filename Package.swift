// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "nori",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "nori", targets: ["nori"])
    ],
    dependencies: [
        .package(url: "https://github.com/migueldeicaza/SwiftTerm.git", from: "1.2.0")
    ],
    targets: [
        .executableTarget(
            name: "nori",
            dependencies: ["SwiftTerm"],
            path: "Sources"
        )
    ]
)
