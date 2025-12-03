import XCTest
@testable import GolfKit

final class DistanceTests: XCTestCase {
  func testDistanceCalculator_samePoint() {
    let a = CLLocationCoordinate2D(latitude: 1.0, longitude: 103.0)
    let d = DistanceCalculator.distanceMeters(from: a, to: a)
    XCTAssertEqual(d, 0)
  }
  func testPlaysLikeAdjustment() {
    let flat = 100.0
    let played = PlaysLikeCalculator.playsLikeDistanceMeters(flatDistance: flat, elevationDeltaMeters: 10)
    XCTAssertGreaterThan(played, flat)
  }
}
