import Foundation
import CoreLocation

public struct OverlayModel: Hashable {
  public let id: String
  public let center: CLLocationCoordinate2D
  public let radius: CLLocationDistance
}

public struct OverlayDiff {
  public let toAdd: [OverlayModel]
  public let toRemove: [String]
  public let toUpdate: [OverlayModel]

  public init(old: [OverlayModel], new: [OverlayModel]) {
    let oldMap = Dictionary(uniqueKeysWithValues: old.map { ($0.id, $0) })
    let newMap = Dictionary(uniqueKeysWithValues: new.map { ($0.id, $0) })
    self.toAdd = new.filter { oldMap[$0.id] == nil }
    self.toRemove = old.compactMap { newMap[$0.id] == nil ? $0.id : nil }
    self.toUpdate = new.filter { oldMap[$0.id] != nil && oldMap[$0.id] != $0 }
  }
}
