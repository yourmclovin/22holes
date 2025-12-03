import MapKit

public extension MKMapView {
  func focus(on coordinate: CLLocationCoordinate2D, radiusMeters: CLLocationDistance, animated: Bool = true) {
    let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: radiusMeters*2.2, longitudinalMeters: radiusMeters*2.2)
    setRegion(regionThatFits(region), animated: animated)
  }
}
