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
    map.preferredConfiguration = MKStandardMapConfiguration(elevationStyle: .realistic)
    return map
  }

  public func updateUIView(_ uiView: MKMapView, context: Context) {
    // Efficient overlays update
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

    // Optionally focus camera if coordinator requested
    if let focus = context.coordinator.pendingCameraFocus {
      focusMap(on: uiView, target: focus.target, includeUser: focus.includeUser)
      context.coordinator.pendingCameraFocus = nil
    }
  }

  private func focusMap(on mapView: MKMapView, target: CLLocationCoordinate2D, includeUser: Bool) {
    var rect = MKMapRect.null
    let targetPoint = MKMapPoint(target)
    rect = rect.union(MKMapRect(origin: targetPoint, size: MKMapSize(width: 0, height: 0)))
    if includeUser, let user = mapView.userLocation.location?.coordinate {
      let p = MKMapPoint(user)
      rect = rect.union(MKMapRect(origin: p, size: MKMapSize(width: 0, height: 0)))
    }
    let padding = UIEdgeInsets(top: 160, left: 40, bottom: 40, right: 40)
    mapView.setVisibleMapRect(rect, edgePadding: padding, animated: true)
  }

  public func makeCoordinator() -> Coordinator { Coordinator(self) }

  public final class Coordinator: NSObject, MKMapViewDelegate {
    var parent: GolfMapView
    var pendingCameraFocus: (target: CLLocationCoordinate2D, includeUser: Bool)?

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
        renderer.lineWidth = 1.5
        renderer.fillColor = renderer.strokeColor.withAlphaComponent(0.06)
        renderer.lineDashPattern = [6,4]
        return renderer
      }
      return MKOverlayRenderer(overlay: overlay)
    }

    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
      if annotation is MKUserLocation { return nil }
      let title = (annotation.title ?? "").flatMap { $0 } ?? ""
      let id = "yardagePin-\(title)"
      var view = mapView.dequeueReusableAnnotationView(withIdentifier: id) as? MKMarkerAnnotationView
      if view == nil {
        let v = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: id)
        v.canShowCallout = false
        v.markerTintColor = (title == "Front" ? .systemGreen : title == "Middle" ? .systemYellow : .systemRed)
        v.glyphText = String(title.prefix(1))
        v.displayPriority = .required
        view = v
      } else {
        view?.annotation = annotation
      }
      return view
    }
  }
}
