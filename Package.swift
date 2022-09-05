// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "Swrve-mParticle",
    platforms: [.iOS(.v10), .tvOS(.v9)],
    products: [
        .library(
            name: "Swrve-mParticle",
            targets: ["Swrve-mParticle"])
    ],
    dependencies: [
         .package(name: "mParticle-Apple-SDK",
                  url: "https://github.com/mParticle/mparticle-apple-sdk",
                  .upToNextMajor(from: "8.8.0")),
         .package(name: "SwrveSDK",
                  url: "https://github.com/swrve/swrve-ios-sdk",
                  .upToNextMajor(from: "8.0.0"))
       ],
    targets: [
        .target(
            name: "Swrve-mParticle",
            dependencies: [
                      .product(name: "mParticle-Apple-SDK", package: "mParticle-Apple-SDK"),
                      .product(name: "SwrveSDK", package: "SwrveSDK")
                    ],
            path: "Swrve-mParticle"
        )
    ],
    swiftLanguageVersions: [.v5]
)

