import Foundation
import CoreLocation

public struct PlaysLikeCalculator {
  // k tuning constant default 0.05
  public static func playsLikeDistance(givenDistance d: Double,
                                      windSpeed mps: Double,
                                      windBearing degWind: Double,
                                      shotBearing degShot: Double,
                                      k: Double = 0.05) -> Double {
    let windRad = degWind * .pi / 180
    let shotRad = degShot * .pi / 180
    let relative = cos(windRad - shotRad) // 1 = tailwind, -1 = headwind
    let effective = mps * (-relative) // headwind positive effect
    return max(0, d * (1 + k * effective))
  }
}
