import Foundation
import CoreLocation

public protocol LocationManagerType: AnyObject {
  var lastCoordinate: CLLocationCoordinate2D? { get }
  var lastHeading: CLLocationDirection? { get }
  func startUpdating()
  func stopUpdating()
  func subscribe(_ callback: @escaping (CLLocation, CLLocationDirection?) -> Void) -> AnyObject
  func unsubscribe(_ token: AnyObject)
}

public extension LocationManagerType {
  /// Default AsyncSequence adapter for LocationManagerType
  func locationStream() -> AsyncStream<(CLLocation, CLLocationDirection?)> {
    AsyncStream { continuation in
      let token = subscribe { location, heading in
        continuation.yield((location, heading))
      }
      startUpdating()
      continuation.onTermination = { @Sendable _ in
        stopUpdating()
        unsubscribe(token)
      }
    }
  }
}
