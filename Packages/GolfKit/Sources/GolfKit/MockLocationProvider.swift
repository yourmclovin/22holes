import Foundation
import CoreLocation

public protocol LocationProviding {
  var lastCoordinate: CLLocationCoordinate2D? { get }
}

public final class MockLocationProvider: LocationProviding {
  public var lastCoordinate: CLLocationCoordinate2D?

  public init(lat: Double = 1.3000, lon: Double = 103.8000) {
    self.lastCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
  }
}
