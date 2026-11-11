// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "Krea2ReferenceTools",
    products: [
        .library(name: "ReferenceCrop", targets: ["ReferenceCrop"]),
        .executable(name: "krea2-crop", targets: ["Krea2Crop"])
    ],
    targets: [
        .target(name: "ReferenceCrop"),
        .executableTarget(name: "Krea2Crop", dependencies: ["ReferenceCrop"])
    ]
)
