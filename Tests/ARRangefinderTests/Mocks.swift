import Foundation
import CoreHaptics
import ARKit
@testable import _22holes_iOS

final class MockHaptics: HapticControlling {
  var playCount = 0
  func playStableHit() { playCount += 1 }
  func stop() {}
}

extension simd_float4x4 {
  init(translation: SIMD3<Float>) {
    self = matrix_identity_float4x4
    columns.3 = SIMD4<Float>(translation.x, translation.y, translation.z, 1)
  }
}

extension ARFrame {
  static func mock(distanceMeters: Double) -> ARFrame {
    // Minimal stub using a private initializer is not possible; instead we create a fake frame via performing operations not available in tests.
    fatalError("ARFrame mocking to be implemented per platform; test will be adjusted in CI for device runs")
  }
}
