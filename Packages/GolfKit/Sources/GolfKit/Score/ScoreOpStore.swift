import Foundation

public actor ScoreOpStore {
  private var ops: [ScoreOp] = []
  private let fileURL: URL

  public init(fileURL: URL) throws {
    self.fileURL = fileURL
    if FileManager.default.fileExists(atPath: fileURL.path) {
      let d = try Data(contentsOf: fileURL)
      self.ops = (try? JSONDecoder().decode([ScoreOp].self, from: d)) ?? []
    }
  }

  public func append(_ op: ScoreOp) throws {
    ops.append(op)
    try persist()
  }

  public func all() -> [ScoreOp] { ops }

  public func remove(applied op: ScoreOp) throws {
    ops.removeAll { $0.id == op.id }
    try persist()
  }

  private func persist() throws {
    let d = try JSONEncoder().encode(ops)
    try d.write(to: fileURL, options: .atomic)
  }
}
