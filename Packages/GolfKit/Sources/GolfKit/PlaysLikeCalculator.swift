import Foundation
import CoreLocation

public struct PlaysLikeCalculator {
  /// Adjusts a base distance based on wind speed and relative bearing.
  /// Simple model: effectiveDistance = distance - windEffect
  /// windEffect = sign * distance * k * (windSpeed / 10) where sign = +1 for headwind, -1 for tailwind
  /// k is tuning constant (e.g., 0.05)
  public static func playsLikeDistance(baseDistance: Double, windSpeedMetersPerSecond: Double, windBearing: Double?, shotBearing: Double, k: Double = 0.05) -> Double {
    guard windSpeedMetersPerSecond > 0, let wBearing = windBearing else { return baseDistance }
    let angleDiff = angleBetween(bearing1: shotBearing, bearing2: wBearing)
    // headwind when angleDiff near 180, tailwind near 0
    let headwindFactor = cos(angleDiff * .pi / 180.0) * -1.0 // cos(180)= -1 -> headwindFactor = 1
    let windEffect = baseDistance * k * (windSpeedMetersPerSecond / 10.0) * headwindFactor
    return max(1.0, baseDistance + windEffect)
  }

  private static func angleBetween(bearing1: Double, bearing2: Double) -> Double {
    let diff = abs(bearing1 - bearing2).truncatingRemainder(dividingBy: 360)
    return diff > 180 ? 360 - diff : diff
  }
}
