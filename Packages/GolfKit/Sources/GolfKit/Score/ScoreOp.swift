import Foundation

public struct ScoreOp: Codable, Hashable {
  public let id: UUID
  public let roundID: UUID
  public let holeIndex: Int
  public let field: String
  public let value: Int
  public let authorID: String?
  public let occurredAt: Date

  public init(id: UUID = UUID(), roundID: UUID, holeIndex: Int, field: String, value: Int, authorID: String? = nil, occurredAt: Date = Date()) {
    self.id = id
    self.roundID = roundID
    self.holeIndex = holeIndex
    self.field = field
    self.value = value
    self.authorID = authorID
    self.occurredAt = occurredAt
  }
}
