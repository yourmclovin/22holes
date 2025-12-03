import Foundation
import SwiftData

@Model
public final class SDAppSettings {
  @Attribute(.unique) public var id: UUID = UUID()
  public var useMetric: Bool
  public var shareLocation: Bool
  // NEW: control auto-detect haptics
  public var enableAutoDetectHaptics: Bool

  public init(useMetric: Bool = true, shareLocation: Bool = true, enableAutoDetectHaptics: Bool = true) {
    self.useMetric = useMetric
    self.shareLocation = shareLocation
    self.enableAutoDetectHaptics = enableAutoDetectHaptics
  }
}
