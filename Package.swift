// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "piggyBankServer",
    platforms: [
        .iOS(.v13),
       .macOS(.v12)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework. 
        .package(url: "https://github.com/vapor/vapor.git", from: "4.76.0"),
        .package(url: "https://github.com/stephencelis/SQLite.swift.git", from: "0.14.1")
    ],
    targets: [
        .executableTarget(
            name: "PiggyBankServerApp",
            dependencies: [
              .product(name: "Vapor", package: "vapor"),
              .product(name: "SQLite", package: "SQLite.swift")
            ],
            path: "Sources/App",
            swiftSettings: [
                // Enable better optimizations when building in Release configuration. Despite the use of
                // the `.unsafeFlags` construct required by SwiftPM, this flag is recommended for Release
                // builds. See <https://www.swift.org/server/guides/building.html#building-for-production> for details.
                .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release))
            ]
        ),
        .testTarget(name: "PiggyBankServerAppTests",
            dependencies: [
                .target(name: "PiggyBankServerApp"),
                .product(name: "XCTVapor", package: "vapor"),
            ],
            path: "Tests/AppTests"
        )
    ]
)
