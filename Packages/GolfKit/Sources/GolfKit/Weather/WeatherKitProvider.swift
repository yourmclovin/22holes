import Foundation
import CoreLocation
#if canImport(WeatherKit)
import WeatherKit
#endif

public actor WeatherKitProvider: WeatherProviding {
  private let cache = NSCache<NSString, CachedWeather>()
  private let ttl: TimeInterval

  public init(ttl: TimeInterval = 15 * 60) { self.ttl = ttl }

  public func currentWeather(for location: CLLocationCoordinate2D) async throws -> WeatherSnapshot {
    let key = "\(location.latitude),\(location.longitude)" as NSString
    if let cw = cache.object(forKey: key), Date().timeIntervalSince(cw.timestamp) < ttl {
      return cw.snapshot
    }

    #if canImport(WeatherKit)
    let service = WeatherService.shared
    let cl = CLLocation(latitude: location.latitude, longitude: location.longitude)
    let meteorology = try await service.weather(for: cl)
    let ws = meteorology.currentWeather.wind?.speed?.value ?? 0
    let wb = meteorology.currentWeather.wind?.direction?.degrees ?? 0
    let temp = meteorology.currentWeather.temperature.value
    let snap = WeatherSnapshot(timestamp: Date(), windSpeedMetersPerSecond: ws, windBearingDegrees: wb, temperatureC: temp, pressureHPa: meteorology.currentWeather.pressure?.value)
    cache.setObject(CachedWeather(snapshot: snap), forKey: key)
    return snap
    #else
    throw NSError(domain: "WeatherKitProvider", code: 1, userInfo: [NSLocalizedDescriptionKey: "WeatherKit not available in this build"])    
    #endif
  }
}

private final class CachedWeather {
  let snapshot: WeatherSnapshot
  let timestamp: Date
  init(snapshot: WeatherSnapshot) { self.snapshot = snapshot; self.timestamp = Date() }
}
