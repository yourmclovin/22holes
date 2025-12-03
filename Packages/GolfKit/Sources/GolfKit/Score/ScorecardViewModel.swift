import Foundation
import Combine

@MainActor
public class ScorecardViewModel: ObservableObject {
  @Published public private(set) var roundID: UUID
  private let sync: ScoreSyncManager
  private let undoStack = UndoStack()
  private let authorID: String

  public init(roundID: UUID, sync: ScoreSyncManager, authorID: String) {
    self.roundID = roundID
    self.sync = sync
    self.authorID = authorID
  }

  public func applyChange(holeIndex: Int, field: String, newValue: Int) async throws {
    // In real app, read previous value from SwiftData model; here we compute inverse op conservatively
    let op = ScoreOp(roundID: roundID, holeIndex: holeIndex, field: field, value: newValue, authorID: authorID)
    // push inverse (local undo) - inverter should read real previous value; simplified here
    try await undoStack.push(op)
    try await sync.handleLocalOp(op)
  }

  public func undoLast() async {
    guard let op = await undoStack.pop() else { return }
    // Create reverse op: in real app, determine previous value; here we mark a reverse with same value negated for example
    let reverse = ScoreOp(roundID: op.roundID, holeIndex: op.holeIndex, field: op.field, value: op.value == 0 ? 0 : op.value - 1, authorID: authorID)
    try? await sync.handleLocalOp(reverse)
  }
}
