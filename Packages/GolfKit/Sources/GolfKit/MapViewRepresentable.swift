import SwiftUI
import MapKit

public struct GolfMapView: UIViewRepresentable {
  public typealias UIViewType = MKMapView

  @Binding private var overlays: [MKOverlay]
  @Binding private var annotations: [MKAnnotation]

  public init(overlays: Binding<[MKOverlay]>, annotations: Binding<[MKAnnotation]>) {
    self._overlays = overlays
    self._annotations = annotations
  }

  public func makeUIView(context: Context) -> MKMapView {
    let map = MKMapView(frame: .zero)
    map.delegate = context.coordinator
    map.mapType = .mutedStandard
    map.showsUserLocation = true
    map.pointOfInterestFilter = .excludingAll
    map.isRotateEnabled = false
    return map
  }

  public func updateUIView(_ uiView: MKMapView, context: Context) {
    // Efficiently update overlays: remove ones that are not in new set, add missing
    let current = Set(uiView.overlays.map { $0 as MKOverlay })
    let next = Set(overlays.map { $0 as MKOverlay })

    let toRemove = current.subtracting(next)
    let toAdd = next.subtracting(current)

    if !toRemove.isEmpty { uiView.removeOverlays(Array(toRemove)) }
    if !toAdd.isEmpty { uiView.addOverlays(Array(toAdd)) }

    // Annotations
    let existing = Set(uiView.annotations.filter { !($0 is MKUserLocation) })
    let desired = Set(annotations)
    let removeA = existing.subtracting(desired)
    let addA = desired.subtracting(existing)
    if !removeA.isEmpty { uiView.removeAnnotations(Array(removeA)) }
    if !addA.isEmpty { uiView.addAnnotations(Array(addA)) }
  }

  public func makeCoordinator() -> Coordinator { Coordinator(self) }

  public final class Coordinator: NSObject, MKMapViewDelegate {
    var parent: GolfMapView
    init(_ parent: GolfMapView) { self.parent = parent }

    public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
      if let circle = overlay as? MKCircle {
        let renderer = MKCircleRenderer(circle: circle)
        // determine ring color by radius
        switch circle.radius {
        case YardageRing.ring50.radiusMeters:
          renderer.strokeColor = YardageRing.ring50.strokeColor
        case YardageRing.ring100.radiusMeters:
          renderer.strokeColor = YardageRing.ring100.strokeColor
        case YardageRing.ring150.radiusMeters:
          renderer.strokeColor = YardageRing.ring150.strokeColor
        default:
          renderer.strokeColor = UIColor.systemBlue
        }
        renderer.lineWidth = 2
        renderer.fillColor = renderer.strokeColor.withAlphaComponent(0.08)
        return renderer
      }
      return MKOverlayRenderer(overlay: overlay)
    }

    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
      if annotation is MKUserLocation { return nil }
      let id = "yardagePin"
      var view = mapView.dequeueReusableAnnotationView(withIdentifier: id)
      if view == nil {
        view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: id)
        view?.canShowCallout = false
      } else {
        view?.annotation = annotation
      }
      return view
    }
  }
}
