import Foundation

public actor UndoStack {
  private var stack: [ScoreOp] = []

  public init() {}

  public func push(_ op: ScoreOp) { stack.append(op) }
  public func pop() -> ScoreOp? { stack.popLast() }
  public func clear() { stack.removeAll(keepingCapacity: false) }
  public func all() -> [ScoreOp] { stack }
}
