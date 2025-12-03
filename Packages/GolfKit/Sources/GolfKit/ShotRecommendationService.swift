import Foundation
import CoreLocation

public actor ShotRecommendationService {
  public let weatherProvider: WeatherProviding

  public init(weatherProvider: WeatherProviding) {
    self.weatherProvider = weatherProvider
  }

  /// Returns plays-like distances for front/middle/back (meters).
  public func playsLikeDistances(for hole: Hole, userLocation: CLLocationCoordinate2D, shotBearing: Double) async -> (front: Double, middle: Double, back: Double) {
    do {
      let snap = try await weatherProvider.snapshot(for: hole.greenCoordinate.clCoordinate)
      let windSpeed = snap.windSpeedMetersPerSecond ?? 0
      let windBearing = snap.windBearing

      let front = PlaysLikeCalculator.playsLikeDistance(baseDistance: hole.frontDistanceMeters,
                                                        windSpeedMetersPerSecond: windSpeed,
                                                        windBearing: windBearing,
                                                        shotBearing: shotBearing)
      let middle = PlaysLikeCalculator.playsLikeDistance(baseDistance: hole.middleDistanceMeters,
                                                         windSpeedMetersPerSecond: windSpeed,
                                                         windBearing: windBearing,
                                                         shotBearing: shotBearing)
      let back = PlaysLikeCalculator.playsLikeDistance(baseDistance: hole.backDistanceMeters,
                                                       windSpeedMetersPerSecond: windSpeed,
                                                       windBearing: windBearing,
                                                       shotBearing: shotBearing)
      return (front, middle, back)
    } catch {
      // On error, return base distances
      return (hole.frontDistanceMeters, hole.middleDistanceMeters, hole.backDistanceMeters)
    }
  }
}
