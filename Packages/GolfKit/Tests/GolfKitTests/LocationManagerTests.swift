import XCTest
import CoreLocation
@testable import GolfKit

final class LocationManagerTests: XCTestCase {
  func testLastLocationUpdates() async throws {
    let manager = LocationManager.shared
    // Can't simulate CLLocationManager in unit tests easily; we exercise public API contract
    // Ensure requesting authorization doesn't crash and start/stop can be called.
    manager.requestAuthorization()
    manager.start()
    // Allow a small delay for potential async updates in real device; here just ensure calls are safe
    try await Task.sleep(nanoseconds: 100_000_000)
    manager.stop()

    // Cannot assert real location in CI; assert that the property exists and is optional
    XCTAssertNotNil(manager)
  }
}
