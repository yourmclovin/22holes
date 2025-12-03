import Foundation
import SwiftData

@Model
public final class SDAppSettings: Codable, Identifiable {
  @Attribute(.unique) public var id: UUID
  public var useMetric: Bool
  public var shareLocation: Bool
  public var clubBag: [SDClub]

  public init(id: UUID = .init(), useMetric: Bool = true, shareLocation: Bool = false, clubBag: [SDClub] = []) {
    self.id = id
    self.useMetric = useMetric
    self.shareLocation = shareLocation
    self.clubBag = clubBag
  }
}
