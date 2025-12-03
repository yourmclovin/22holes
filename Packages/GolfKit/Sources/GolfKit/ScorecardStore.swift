import Foundation
import SwiftData

public protocol ScorecardStore {
  func createRound(courseId: String) async -> SDRound
  func addStroke(round: SDRound, holeIndex: Int) async
  func removeLastStroke(round: SDRound, holeIndex: Int) async
  func undoLastChange(round: SDRound) async
  func save(round: SDRound) async
}

public final class DefaultScorecardStore: ScorecardStore {
  private let context: ModelContext
  private var undoStack: [() async -> Void] = []
  private let queue = DispatchQueue(label: "com.yourmclovin.scorecardstore", qos: .userInitiated)

  public init(context: ModelContext) {
    self.context = context
  }

  public func createRound(courseId: String) async -> SDRound {
    let round = SDRound(courseId: courseId)
    await context.perform { context.insert(round) }
    return round
  }

  public func addStroke(round: SDRound, holeIndex: Int) async {
    await context.perform {
      if let idx = round.holeStates.firstIndex(where: { $0.holeIndex == holeIndex }) {
        var hs = round.holeStates
        hs[idx].strokes.append(1)
        round.holeStates = hs

        let undo: () async -> Void = { [weak self] in
          await self?.context.perform {
            var hs = round.holeStates
            _ = hs[idx].strokes.popLast()
            round.holeStates = hs
          }
        }
        self.undoStack.append(undo)
      } else {
        var hs = round.holeStates
        hs.append(SDHoleState(holeIndex: holeIndex, strokes: [1], putts: 0))
        round.holeStates = hs
        let newIndex = hs.count - 1
        let undo: () async -> Void = { [weak self] in
          await self?.context.perform {
            var hs = round.holeStates
            hs.remove(at: newIndex)
            round.holeStates = hs
          }
        }
        self.undoStack.append(undo)
      }
    }
  }

  public func removeLastStroke(round: SDRound, holeIndex: Int) async {
    await context.perform {
      guard let idx = round.holeStates.firstIndex(where: { $0.holeIndex == holeIndex }), !round.holeStates[idx].strokes.isEmpty else { return }
      var hs = round.holeStates
      let removed = hs[idx].strokes.removeLast()
      round.holeStates = hs

      let undo: () async -> Void = { [weak self] in
        await self?.context.perform {
          var hs = round.holeStates
          hs[idx].strokes.append(removed)
          round.holeStates = hs
        }
      }
      self.undoStack.append(undo)
    }
  }

  public func undoLastChange(round: SDRound) async {
    guard let last = undoStack.popLast() else { return }
    await last()
  }

  public func save(round: SDRound) async {
    await context.perform { /* SwiftData auto-saves in many cases; nothing else to do here */ }
  }
}
