import XCTest
@testable import GolfKit

final class ScoreSyncTests: XCTestCase {
  func testLocalThenRemoteConflictLWW() async throws {
    let temp = FileManager.default.temporaryDirectory.appendingPathComponent("scoreops_test.json")
    try? FileManager.default.removeItem(at: temp)
    let store = try ScoreOpStore(fileURL: temp)

    class MockRoundSync: RoundSyncServiceProtocol {
      func sendOp(_ op: ScoreOp) async throws {}
    }

    var applied: [ScoreOp] = []
    let manager = ScoreSyncManager(opStore: store, roundSync: MockRoundSync(), modelUpdater: { applied.append($0) })

    let round = UUID()
    let local = ScoreOp(roundID: round, holeIndex: 1, field: "strokes", value: 4, authorID: "A", occurredAt: Date())
    try await manager.handleLocalOp(local)

    // remote older op should be ignored
    let older = ScoreOp(id: UUID(), roundID: round, holeIndex: 1, field: "strokes", value: 6, authorID: "B", occurredAt: Date(timeIntervalSinceNow: -60))
    await manager.handleRemoteOp(older)

    XCTAssertEqual(applied.last?.value, 4)
  }
}
