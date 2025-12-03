import Foundation
import CoreLocation

public struct DistanceCalculator {
  public static func distanceMeters(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> CLLocationDistance {
    let a = CLLocation(latitude: from.latitude, longitude: from.longitude)
    let b = CLLocation(latitude: to.latitude, longitude: to.longitude)
    return a.distance(from: b)
  }
}
