import XCTest
@testable import GolfKit
import SwiftData

final class ScorecardStoreTests: XCTestCase {
  var modelContext: ModelContext!
  var store: DefaultScorecardStore!

  override func setUp() async throws {
    modelContext = try await TestModelContextBuilder.makeModelContext(for: [SDRound.self])
    store = DefaultScorecardStore(context: modelContext)
  }

  func testCreateRound_andAddStrokeUndo() async throws {
    let round = await store.createRound(courseId: "test-course")
    await store.addStroke(round: round, holeIndex: 1)
    XCTAssertEqual(round.holeStates.count, 1)
    XCTAssertEqual(round.holeStates[0].strokes.count, 1)

    await store.undoLastChange(round: round)
    XCTAssertEqual(round.holeStates.count, 0)
  }

  func testAddAndRemoveStroke() async throws {
    let round = await store.createRound(courseId: "c")
    await store.addStroke(round: round, holeIndex: 1)
    await store.addStroke(round: round, holeIndex: 1)
    XCTAssertEqual(round.holeStates[0].strokes.count, 2)
    await store.removeLastStroke(round: round, holeIndex: 1)
    XCTAssertEqual(round.holeStates[0].strokes.count, 1)
  }
}
