import Foundation

final class MockRoundSync: RoundSyncServiceProtocol {
  var sent: [ScoreOp] = []
  var shouldFail = false

  func sendOp(_ op: ScoreOp) async throws {
    if shouldFail { throw NSError(domain: "MockRoundSync", code: 1) }
    sent.append(op)
  }
}
