import Foundation
import SwiftData

@Model
public final class SDRound: ObservableObject, Identifiable {
  @Attribute(.unique) public var id: UUID = UUID()
  public var courseId: String
  public var startedAt: Date
  public var completedAt: Date?
  @Attribute(.storageLength(1_000_000)) public var holeStatesData: Data

  public init(courseId: String, startedAt: Date = Date(), holeStates: [SDHoleState] = []) {
    self.courseId = courseId
    self.startedAt = startedAt
    self.completedAt = nil
    self.holeStatesData = try! JSONEncoder().encode(holeStates)
  }

  public var holeStates: [SDHoleState] {
    get { (try? JSONDecoder().decode([SDHoleState].self, from: holeStatesData)) ?? [] }
    set { holeStatesData = (try? JSONEncoder().encode(newValue)) ?? Data() }
  }
}

public struct SDHoleState: Codable, Sendable, Equatable {
  public var holeIndex: Int
  public var strokes: [Int]
  public var putts: Int

  public init(holeIndex: Int, strokes: [Int] = [], putts: Int = 0) {
    self.holeIndex = holeIndex
    self.strokes = strokes
    self.putts = putts
  }
}
