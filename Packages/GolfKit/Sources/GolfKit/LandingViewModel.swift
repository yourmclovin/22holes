import Foundation
import CoreLocation
import SwiftUI
import SwiftData

@MainActor
public final class LandingViewModel: ObservableObject {
  @Published public var playerCoordinate: CLLocationCoordinate2D?
  @Published public var currentCourse: SDCourse?
  @Published public var holeIndex: Int = 1
  @Published public var par: Int = 4
  @Published public var distanceToGreen: Double = 0
  @Published public var detectedHole: DetectedHole?
  @Published public var recentlySwitched: Bool = false

  private let detector = AutoHoleDetector()
  private let locationManager: LocationManagerType
  private var locationTask: Task<Void, Never>?
  private var modelContext: ModelContext?

  // caching overlays to avoid re-creating on every location update
  private var cachedHoleIndex: Int?
  private var cachedOverlays: [MKOverlay] = []
  private var cachedAnnotations: [MKAnnotation] = []

  // haptic cooldown
  private var lastHapticDate: Date = .distantPast
  private let hapticCooldown: TimeInterval = 5.0

  public init(locationManager: LocationManagerType = LocationManager.shared, modelContext: ModelContext? = nil) {
    self.locationManager = locationManager
    self.modelContext = modelContext
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
      let previousIndex = detectedHole?.holeIndex
      detectedHole = detection
      holeIndex = detection.holeIndex

      // UI feedback
      recentlySwitched = true
      Task { @MainActor in
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        self.recentlySwitched = false
      }

      if shouldFireHaptics() {
        // respect cooldown
        if Date().timeIntervalSince(lastHapticDate) > hapticCooldown {
          fireSwitchHaptic()
          lastHapticDate = Date()
        }
      }

      if course.holes.count >= holeIndex {
        let h = course.holes[holeIndex - 1]
        par = h.par
        distanceToGreen = DistanceCalculator.distanceMeters(from: location.coordinate, to: h.greenCoordinate.clCoordinate)
      }

      // Only update overlays/annotations when hole index changes
      if cachedHoleIndex != detection.holeIndex {
        cachedHoleIndex = detection.holeIndex
        cachedOverlays = YardageOverlayFactory.rings(for: detection.greenCoordinate.clCoordinate)
        cachedAnnotations = YardageOverlayFactory.frontMiddleBackAnnotations(front: detection.hole.frontCoordinate.clCoordinate,
                                                                            middle: detection.hole.middleCoordinate.clCoordinate,
                                                                            back: detection.hole.backCoordinate.clCoordinate)
      }
    }
  }

  public var yardageOverlays: [MKOverlay] { cachedOverlays }
  public var yardageAnnotations: [MKAnnotation] { cachedAnnotations }

  private func shouldFireHaptics() -> Bool {
    guard let ctx = modelContext else { return true }
    do {
      let settings = try ctx.fetch(SDAppSettings.self)
      return settings.first?.enableAutoDetectHaptics ?? true
    } catch {
      return true
    }
  }

  private func fireSwitchHaptic() {
    #if os(iOS)
    let gen = UINotificationFeedbackGenerator()
    gen.prepare()
    gen.notificationOccurred(.success)
    #elseif os(watchOS)
    WKInterfaceDevice.current().play(.success)
    #endif
  }
}
