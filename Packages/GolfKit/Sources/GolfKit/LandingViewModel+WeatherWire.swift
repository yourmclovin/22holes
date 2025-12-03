import Foundation
import CoreLocation
import SwiftUI
import SwiftData

@MainActor
public extension LandingViewModel {
  // wind/plays-like UI
  var windSummary: String? { _windSummary }
  private var _windSummaryStorageKey = "__windSummary"
}

// Add wiring in an extension method to avoid touching the main file too much
@MainActor
public extension LandingViewModel {
  private var _windSummary: String? {
    get { objc_getAssociatedObject(self, &_windSummaryStorageKey) as? String }
    set { objc_setAssociatedObject(self, &_windSummaryStorageKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
  }

  func wireShotService(_ shotService: ShotRecommendationService?) {
    self.shotSvc = shotService
  }

  // call this when detectedHole updates; provides async fetch and UI update
  func fetchPlaysLikeIfNeeded(heading: CLLocationDirection?) {
    guard let detection = detectedHole else { _windSummary = nil; return }
    guard let shotSvc = shotSvc else { _windSummary = nil; return }

    let shotBearing: Double = heading ?? 0
    Task { @MainActor in
      let distances = await shotSvc.playsLikeDistances(for: detection.hole, userLocation: playerCoordinate ?? detection.greenCoordinate.clCoordinate, shotBearing: shotBearing)
      _windSummary = String(format: "F: %dm • M: %dm • B: %dm", Int(distances.front), Int(distances.middle), Int(distances.back))
      // Note: you may want to expose more structured data for UI later
    }
  }
}
