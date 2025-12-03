import XCTest
@testable import GolfKit

final class PlaysLikeTests: XCTestCase {
  func testZeroWind() {
    let d = PlaysLikeCalculator.playsLikeDistance(givenDistance: 150, windSpeed: 0, windBearing: 0, shotBearing: 0)
    XCTAssertEqual(d, 150)
  }

  func testHeadwindIncreasesDistance() {
    let d = PlaysLikeCalculator.playsLikeDistance(givenDistance: 150, windSpeed: 5, windBearing: 180, shotBearing: 0, k: 0.05)
    XCTAssertTrue(d > 150)
  }

  func testTailwindDecreasesDistance() {
    let d = PlaysLikeCalculator.playsLikeDistance(givenDistance: 150, windSpeed: 5, windBearing: 0, shotBearing: 0, k: 0.05)
    XCTAssertTrue(d < 150)
  }
}
