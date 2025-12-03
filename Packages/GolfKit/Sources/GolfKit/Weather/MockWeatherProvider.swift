import Foundation
import CoreLocation

public actor MockWeatherProvider: WeatherProviding {
  private let snapshot: WeatherSnapshot
  public init(snapshot: WeatherSnapshot) { self.snapshot = snapshot }

  public func currentWeather(for location: CLLocationCoordinate2D) async throws -> WeatherSnapshot {
    return snapshot
  }
}
