// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SPlayer",
    platforms: [.iOS(.v10)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SPlayer",
            targets: ["SPlayer"]),
    ],
//    dependencies: [
//        // Dependencies declare other packages that this package depends on.
//        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.2.0")),
//        .package(url: "https://github.com/onevcat/Kingfisher.git", .upToNextMajor(from: "6.0.0")),
//    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
//        .target(name: "MyFirstSPM", dependencies: ["Kingfisher", "Alamofire"])
        .target(
            name: "SPlayer",
            dependencies: []),
//        .testTarget(
//            name: "MyFirstSPMTests",
//            dependencies: ["MyFirstSPM"]),
    ]
)
