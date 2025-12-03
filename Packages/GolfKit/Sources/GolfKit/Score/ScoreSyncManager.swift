import Foundation

public protocol RoundSyncServiceProtocol {
  func sendOp(_ op: ScoreOp) async throws
}

fileprivate struct FieldKey: Hashable {
  let roundID: UUID
  let holeIndex: Int
  let field: String
}

public actor ScoreSyncManager {
  private var appliedOpIDs = Set<UUID>()
  private var lastAppliedAt: [FieldKey: Date] = [:]
  private let modelUpdater: (ScoreOp) -> Void
  private let opStore: ScoreOpStore
  private let roundSync: RoundSyncServiceProtocol

  public init(opStore: ScoreOpStore, roundSync: RoundSyncServiceProtocol, modelUpdater: @escaping (ScoreOp) -> Void) {
    self.opStore = opStore
    self.roundSync = roundSync
    self.modelUpdater = modelUpdater
  }

  public func handleLocalOp(_ op: ScoreOp) async throws {
    guard !appliedOpIDs.contains(op.id) else { return }
    try await opStore.append(op)
    appliedOpIDs.insert(op.id)
    applyIfNewer(op)
    try await roundSync.sendOp(op)
  }

  public func handleRemoteOp(_ op: ScoreOp) async {
    guard !appliedOpIDs.contains(op.id) else { return }
    appliedOpIDs.insert(op.id)
    applyIfNewer(op)
    try? await opStore.remove(applied: op)
  }

  private func applyIfNewer(_ op: ScoreOp) {
    let key = FieldKey(roundID: op.roundID, holeIndex: op.holeIndex, field: op.field)
    if let last = lastAppliedAt[key], last > op.occurredAt { return }
    lastAppliedAt[key] = op.occurredAt
    modelUpdater(op)
  }
}
