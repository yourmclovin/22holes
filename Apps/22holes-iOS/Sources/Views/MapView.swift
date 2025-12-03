import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
  var playerCoordinate: CLLocationCoordinate2D?
  var course: GolfCourse?

  func makeUIView(context: Context) -> MKMapView {
    let map = MKMapView(frame: .zero)
    map.showsUserLocation = true
    map.pointOfInterestFilter = .excludingAll
    map.mapType = .mutedStandard
    return map
  }

  func updateUIView(_ uiView: MKMapView, context: Context) {
    uiView.removeAnnotations(uiView.annotations)
    if let player = playerCoordinate {
      let ann = MKPointAnnotation()
      ann.coordinate = player
      ann.title = "You"
      uiView.addAnnotation(ann)
      uiView.setCenter(player, animated: false)
    }
    uiView.removeOverlays(uiView.overlays)
    if let hole = course?.holes.first {
      let ann = MKPointAnnotation()
      ann.coordinate = hole.greenCoordinate.clCoordinate
      ann.title = "Green"
      uiView.addAnnotation(ann)

      let rings = [50,100,150].map { MKCircle(center: hole.greenCoordinate.clCoordinate, radius: CLLocationDistance($0)) }
      uiView.addOverlays(rings)
      uiView.delegate = context.coordinator
    }
  }

  func makeCoordinator() -> Coordinator { Coordinator() }
  class Coordinator: NSObject, MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
      if let circle = overlay as? MKCircle {
        let r = MKCircleRenderer(circle: circle)
        r.strokeColor = UIColor.systemGreen.withAlphaComponent(0.6)
        r.lineWidth = 1
        r.fillColor = UIColor.systemGreen.withAlphaComponent(0.08)
        return r
      }
      return MKOverlayRenderer()
    }
  }
}
