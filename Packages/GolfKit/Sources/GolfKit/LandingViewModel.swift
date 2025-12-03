import Foundation
import CoreLocation
import SwiftUI

@MainActor
public final class LandingViewModel: ObservableObject {
  @Published public var playerCoordinate: CLLocationCoordinate2D?
  @Published public var currentCourse: SDCourse?
  @Published public var holeIndex: Int = 1
  @Published public var par: Int = 4
  @Published public var distanceToGreen: Double = 0
  @Published public var detectedHole: DetectedHole?

  private let detector = AutoHoleDetector()
  private let locationManager: LocationManagerType
  private var locationTask: Task<Void, Never>?

  public init(locationManager: LocationManagerType = LocationManager.shared) {
    self.locationManager = locationManager
    self.playerCoordinate = locationManager.lastCoordinate
  }

  public func startLocationUpdates() {
    guard locationTask == nil else { return }
    locationTask = Task { @MainActor in
      let stream = locationManager.locationStream()
      for await (location, heading) in stream {
        await handleLocationUpdate(location, heading: heading)
      }
    }
  }

  public func stopLocationUpdates() {
    locationTask?.cancel()
    locationTask = nil
    locationManager.stopUpdating()
  }

  @MainActor
  public func handleLocationUpdate(_ location: CLLocation, heading: CLLocationDirection?) async {
    playerCoordinate = location.coordinate

    if let course = currentCourse, course.holes.count >= holeIndex {
      let hole = course.holes[holeIndex - 1]
      distanceToGreen = DistanceCalculator.distanceMeters(from: location.coordinate, to: hole.greenCoordinate.clCoordinate)
    }

    guard let course = currentCourse else { return }

    if let detection = await detector.update(location: location, heading: heading, holes: course.holes) {
      detectedHole = detection
      holeIndex = detection.holeIndex
      if course.holes.count >= holeIndex {
        let h = course.holes[holeIndex - 1]
        par = h.par
        distanceToGreen = DistanceCalculator.distanceMeters(from: location.coordinate, to: h.greenCoordinate.clCoordinate)
      }
    }
  }
}
