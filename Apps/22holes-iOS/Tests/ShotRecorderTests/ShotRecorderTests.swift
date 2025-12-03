import XCTest
@testable import GolfKit

final class ShotRecorderTests: XCTestCase {
    func testRecordAndUndo() async throws {
        let recorder = ShotRecorder(context: nil)
        let shot = ShotRecordModel(club: "7I", distanceMeters: 140)
        try await recorder.recordShot(shot)
        var all = await recorder.fetchAllShots()
        XCTAssertEqual(all.count, 0) // no SwiftData context
        try await recorder.undoLastShot() // should not throw
    }
}
