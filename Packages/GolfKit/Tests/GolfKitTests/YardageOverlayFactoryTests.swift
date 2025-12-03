import XCTest
import MapKit
@testable import GolfKit

final class YardageOverlayFactoryTests: XCTestCase {

  func testRingsCountAndRadius() {
    let coord = CLLocationCoordinate2D(latitude: 1.0, longitude: 103.0)
    let rings = YardageOverlayFactory.rings(for: coord)
    XCTAssertEqual(rings.count, 3)
    let radii = rings.map { $0.radius }.sorted()
    XCTAssertEqual(radii, [50.0, 100.0, 150.0])
  }

  func testFrontMiddleBackAnnotations() {
    let f = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    let m = CLLocationCoordinate2D(latitude: 1, longitude: 1)
    let b = CLLocationCoordinate2D(latitude: 2, longitude: 2)
    let anns = YardageOverlayFactory.frontMiddleBackAnnotations(front: f, middle: m, back: b)
    XCTAssertEqual(anns.count, 3)
    XCTAssertEqual(anns[0].title, "Front")
    XCTAssertEqual(anns[1].title, "Middle")
    XCTAssertEqual(anns[2].title, "Back")
  }
}
