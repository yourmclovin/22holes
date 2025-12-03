import XCTest
@testable import GolfKit
import CoreLocation

final class OverlayDiffTests: XCTestCase {
  func testDiffAddUpdateRemove() {
    let old: [OverlayModel] = [OverlayModel(id: "a", center: CLLocationCoordinate2D(latitude: 0, longitude: 0), radius: 10),
                              OverlayModel(id: "b", center: CLLocationCoordinate2D(latitude: 1, longitude: 1), radius: 20)]
    let new: [OverlayModel] = [OverlayModel(id: "a", center: CLLocationCoordinate2D(latitude: 0, longitude: 0), radius: 12),
                              OverlayModel(id: "c", center: CLLocationCoordinate2D(latitude: 2, longitude: 2), radius: 30)]

    let diff = OverlayDiff(old: old, new: new)
    XCTAssertEqual(diff.toAdd.map { $0.id }, ["c"]) 
    XCTAssertEqual(diff.toRemove, ["b"]) 
    XCTAssertEqual(diff.toUpdate.map { $0.id }, ["a"]) 
  }
}
