import XCTest
@testable import _22holes_iOS

final class StableDetectionTests: XCTestCase {
  func testStableHapticFiresAfterThreshold() {
    let vc = ARVC()
    let mock = MockHaptics()
    vc.hapticsController = mock
    vc.placeTargetForTest(at: simd_float4x4(translation: [0,0,-2]))
    // feed frames that converge
    for _ in 0..<30 {
      let frame = ARFrame.mock(distanceMeters: 2.0)
      vc.test_receive(frame: frame)
    }
    // should have at least one play
    XCTAssertTrue(mock.playCount >= 1)
  }
}
