// swift-tools-version: 5.10
import PackageDescription
let package = Package(name: "StoreFixture", platforms: [.macOS(.v13)], dependencies: [.package(path: "../..")], targets: [.executableTarget(name: "StoreFixture", dependencies: [.product(name: "FacetCore", package: "facet")])])
