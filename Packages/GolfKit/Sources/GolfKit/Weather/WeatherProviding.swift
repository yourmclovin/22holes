import Foundation
import CoreLocation

public struct WeatherSnapshot: Codable {
  public let timestamp: Date
  public let windSpeedMetersPerSecond: Double
  public let windBearingDegrees: Double
  public let temperatureC: Double
  public let pressureHPa: Double?
}

public protocol WeatherProviding {
  func currentWeather(for location: CLLocationCoordinate2D) async throws -> WeatherSnapshot
}
