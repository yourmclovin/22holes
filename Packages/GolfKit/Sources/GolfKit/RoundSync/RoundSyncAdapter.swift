import Foundation

public final class RoundSyncAdapter: RoundSyncServiceProtocol {
  private let queue: PersistentQueueProtocol
  public init(queue: PersistentQueueProtocol) {
    self.queue = queue
  }

  public func sendOp(_ op: ScoreOp) async throws {
    // Serialize op
    let data = try JSONEncoder().encode(op)
    do {
      try await queue.enqueue(data)
    } catch {
      // rethrow to let caller handle immediate failure
      throw error
    }
  }
}

public protocol PersistentQueueProtocol {
  func enqueue(_ data: Data) async throws
}
