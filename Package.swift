// swift-tools-version: 5.10
import PackageDescription
let package = Package(
    name: "FacetCore",
    platforms: [.macOS(.v13), .iOS("18.0"), .watchOS("11.0")],
    products: [.library(name: "FacetCore", targets: ["FacetCore"])],
    targets: [.target(name: "FacetCore"), .testTarget(name: "FacetCoreTests", dependencies: ["FacetCore"])]
)
