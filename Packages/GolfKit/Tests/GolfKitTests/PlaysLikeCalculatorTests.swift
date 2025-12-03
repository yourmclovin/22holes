import XCTest
@testable import GolfKit

final class PlaysLikeCalculatorTests: XCTestCase {
  func testNoWindReturnsBase() {
    let d = PlaysLikeCalculator.playsLikeDistance(baseDistance: 150, windSpeedMetersPerSecond: 0, windBearing: nil, shotBearing: 0)
    XCTAssertEqual(d, 150)
  }

  func testHeadwindIncreasesDistance() {
    // wind from 180 (headwind for shot 0)
    let d = PlaysLikeCalculator.playsLikeDistance(baseDistance: 150, windSpeedMetersPerSecond: 10, windBearing: 180, shotBearing: 0, k: 0.05)
    XCTAssertGreaterThan(d, 150)
  }

  func testTailwindDecreasesDistance() {
    // wind from 0 (tailwind for shot 0)
    let d = PlaysLikeCalculator.playsLikeDistance(baseDistance: 150, windSpeedMetersPerSecond: 10, windBearing: 0, shotBearing: 0, k: 0.05)
    XCTAssertLessThan(d, 150)
  }
}
