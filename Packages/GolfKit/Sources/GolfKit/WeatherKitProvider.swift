import Foundation
import CoreLocation

public struct WeatherSnapshot: Codable, Sendable {
  public let temperatureC: Double?
  public let windSpeedMetersPerSecond: Double?
  public let windBearing: Double?
  public let timestamp: Date
}

public protocol WeatherProviding {
  func snapshot(for coordinate: CLLocationCoordinate2D) async throws -> WeatherSnapshot
}

// Simple WeatherKit provider scaffold. You must provide WeatherKit keys/entitlements in your app.
public actor WeatherKitProvider: WeatherProviding {
  private var cache: [String: (snapshot: WeatherSnapshot, date: Date)] = [:]
  private let ttl: TimeInterval

  public init(cacheTTL: TimeInterval = 900) { // 15 minutes
    self.ttl = cacheTTL
  }

  public func snapshot(for coordinate: CLLocationCoordinate2D) async throws -> WeatherSnapshot {
    let key = "\(coordinate.latitude),\(coordinate.longitude)"
    if let entry = cache[key], Date().timeIntervalSince(entry.date) < ttl {
      return entry.snapshot
    }

    // Placeholder: call WeatherKit APIs here. For now return a sensible default.
    let snap = WeatherSnapshot(temperatureC: nil, windSpeedMetersPerSecond: 0, windBearing: nil, timestamp: Date())
    cache[key] = (snap, Date())
    return snap
  }
}
