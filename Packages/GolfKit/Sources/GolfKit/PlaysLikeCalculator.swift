import Foundation
import CoreLocation

public struct PlaysLikeCalculator {
  /// Simple placeholder: adjusts distance by elevation delta (meters) using a heuristic:
  /// 1 meter elevation ~= 0.8 meters playing distance (approx). This is tunable.
  public static func playsLikeDistanceMeters(flatDistance: Double, elevationDeltaMeters: Double) -> Double {
    let multiplierPerMeter = 0.8
    return flatDistance + (elevationDeltaMeters * multiplierPerMeter)
  }
}
