import Foundation
import MapKit
import SwiftData

@MainActor
public extension LandingViewModel {
  // Exposed for the Map view
  var yardageOverlays: [MKOverlay] {
    guard let detected = detectedHole else { return [] }
    let center = detected.greenCoordinate.clCoordinate
    return YardageOverlayFactory.rings(for: center)
  }

  var yardageAnnotations: [MKAnnotation] {
    guard let detected = detectedHole else { return [] }
    let h = detected.hole
    return YardageOverlayFactory.frontMiddleBackAnnotations(front: h.frontCoordinate.clCoordinate,
                                                            middle: h.middleCoordinate.clCoordinate,
                                                            back: h.backCoordinate.clCoordinate)
  }
}
