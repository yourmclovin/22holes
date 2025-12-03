import XCTest
@testable import _22holes_iOS

final class ExponentialMovingAverageTests: XCTestCase {
  func testConvergence() {
    let ema = ExponentialMovingAverage(alpha: 0.5)
    var v = ema.update(10)
    XCTAssertEqual(v, 10)
    v = ema.update(20)
    XCTAssertEqual(v, 15)
    v = ema.update(20)
    XCTAssertEqual(v, 17.5)
  }

  func testReset() {
    let ema = ExponentialMovingAverage(alpha: 0.3)
    _ = ema.update(5)
    ema.reset()
    let v = ema.update(7)
    XCTAssertEqual(v, 7)
  }
}
