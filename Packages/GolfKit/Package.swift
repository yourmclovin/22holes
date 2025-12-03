// swift-tools-version:5.9
import PackageDescription

let package = Package(
  name: "GolfKit",
  platforms: [.iOS(.v17), .watchOS(.v10)],
  products: [.library(name: "GolfKit", targets: ["GolfKit"])],
  targets: [
    .target(name: "GolfKit", path: "Sources/GolfKit")
  ]
)
