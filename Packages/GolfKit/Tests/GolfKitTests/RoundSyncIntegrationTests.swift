import XCTest
@testable import GolfKit

final class RoundSyncIntegrationTests: XCTestCase {
  func testEnqueueOnFailureAndReplay() async throws {
    let temp = FileManager.default.temporaryDirectory.appendingPathComponent("queue_test.json")
    try? FileManager.default.removeItem(at: temp)

    // Minimal persistent queue mock
    class InMemoryQueue: PersistentQueueProtocol {
      var items: [Data] = []
      func enqueue(_ data: Data) async throws { items.append(data) }
    }

    let queue = InMemoryQueue()
    let adapter = RoundSyncAdapter(queue: queue)
    let mock = MockRoundSync()

    // Use adapter to enqueue
    let round = UUID()
    let op = ScoreOp(roundID: round, holeIndex: 1, field: "strokes", value: 4, authorID: "A")
    try await adapter.sendOp(op)
    XCTAssertEqual(queue.items.count, 1)

    // Simulate replay: decode and send with mock
    let data = queue.items.removeFirst()
    let decoded = try JSONDecoder().decode(ScoreOp.self, from: data)
    try await mock.sendOp(decoded)
    XCTAssertEqual(mock.sent.count, 1)
    XCTAssertEqual(mock.sent.first?.id, op.id)
  }
}
