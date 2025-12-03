import XCTest
import SwiftUI
@testable import GolfKit

// SnapshotTesting is optional — install via SPM in the test target if not present.
#if canImport(SnapshotTesting)
import SnapshotTesting
#endif

final class WatchSnapshots: XCTestCase {
  override func setUp() async throws {
    // Ensure consistent environment
    isRecording = ProcessInfo.processInfo.environment["RECORD_SNAPSHOTS"] == "1"
  }

  func makeRound(state: SnapshotState) -> SDRound {
    switch state {
    case .empty:
      return SDRound(courseId: "test-course", holeStates: (1...18).map { SDHoleState(holeIndex: $0) })
    case .mid:
      var holes = (1...18).map { SDHoleState(holeIndex: $0) }
      holes[0].strokes = [1,1]
      holes[1].strokes = [1]
      holes[2].strokes = [1,1,1]
      return SDRound(courseId: "test-course", holeStates: holes)
    case .completed:
      let holes = (1...18).map { SDHoleState(holeIndex: $0, strokes: [1,1,1,1]) }
      return SDRound(courseId: "test-course", holeStates: holes)
    }
  }

  enum SnapshotState: String, CaseIterable {
    case empty, mid, completed
  }

  func testWatchScorecardSnapshots_45mm() async throws {
    // Only run if SnapshotTesting is available
    #if canImport(SnapshotTesting)
    let viewSize = CGSize(width: 396, height: 484) // Approx size for 45mm

    for state in SnapshotState.allCases {
      let round = makeRound(state: state)
      let context = try TestModelContextBuilder.makeModelContext(for: [SDRound.self])
      // Insert round into context so ObservedObject can read from it if needed
      await context.perform { context.insert(round) }

      let view = WatchScorecardView(round: round, context: context)
        .frame(width: viewSize.width, height: viewSize.height)

      let host = UIHostingController(rootView: view)

      // Snapshot name includes state and device
      let snapshotName = "WatchScorecard_45mm_\(state.rawValue)"

      // Use record mode via env var RECORD_SNAPSHOTS=1 when creating baselines
      let record = ProcessInfo.processInfo.environment["RECORD_SNAPSHOTS"] == "1"

      assertSnapshot(matching: host, as: .image(size: viewSize), named: snapshotName, record: record)
    }
    #else
    throw XCTSkip("SnapshotTesting not available. Add it to the test target to run these snapshots.")
    #endif
  }
}
