import Foundation
import CoreLocation
import Combine

@MainActor
public final class LocationManager: NSObject, ObservableObject {
  public static let shared = LocationManager()
  @Published public private(set) var lastLocation: CLLocation?

  private let manager = CLLocationManager()

  private override init() {
    super.init()
    manager.delegate = self
    manager.desiredAccuracy = kCLLocationAccuracyBest
    manager.activityType = .fitness
  }

  public func requestAuthorization() {
    manager.requestWhenInUseAuthorization()
  }

  public func start() {
    manager.startUpdatingLocation()
  }

  public func stop() {
    manager.stopUpdatingLocation()
  }
}

extension LocationManager: CLLocationManagerDelegate {
  public func locationManager(_ mgr: CLLocationManager, didUpdateLocations locs: [CLLocation]) {
    lastLocation = locs.last
  }
}
