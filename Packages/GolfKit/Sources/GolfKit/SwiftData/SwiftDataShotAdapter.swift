import Foundation
#if canImport(SwiftData)
import SwiftData
#endif

#if canImport(SwiftData)
@MainActor
public final class SwiftDataShotAdapter {
  private let context: ModelContext
  public init(context: ModelContext) {
    self.context = context
  }

  public func fetchRecentShots(limit: Int = 2000) async -> [ShotRecord] {
    // Assumes your SwiftData entity is named `Shot` with properties matching names below.
    // If your entity names differ, adapt the key paths accordingly.
    let request = FetchDescriptor<Shot>(sortBy: [\.-Shot.timestamp], limit: limit)
    do {
      let results = try context.fetch(request)
      return results.map { s in
        ShotRecord(id: s.id ?? UUID(),
                   club: s.club ?? "Unknown",
                   distanceMeters: s.distanceMeters,
                   windSpeedMps: s.windSpeedMps,
                   windDirDeg: s.windDirDeg,
                   lieType: s.lieType,
                   timestamp: s.timestamp ?? Date())
      }
    } catch {
      return []
    }
  }
}
#endif
