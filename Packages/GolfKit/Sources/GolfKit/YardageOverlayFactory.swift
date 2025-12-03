import Foundation
import MapKit

public enum YardageRing: CaseIterable {
  case ring50, ring100, ring150

  public var radiusMeters: CLLocationDistance {
    switch self {
    case .ring50: return 50
    case .ring100: return 100
    case .ring150: return 150
    }
  }

  public var strokeColor: UIColor {
    switch self {
    case .ring50: return UIColor.systemGreen
    case .ring100: return UIColor.systemYellow
    case .ring150: return UIColor.systemRed
    }
  }
}

public struct YardageOverlayFactory {
  public static func rings(for coordinate: CLLocationCoordinate2D) -> [MKCircle] {
    YardageRing.allCases.map { MKCircle(center: coordinate, radius: $0.radiusMeters) }
  }

  public static func frontMiddleBackAnnotations(front: CLLocationCoordinate2D, middle: CLLocationCoordinate2D, back: CLLocationCoordinate2D) -> [MKPointAnnotation] {
    let f = MKPointAnnotation(); f.coordinate = front; f.title = "Front"
    let m = MKPointAnnotation(); m.coordinate = middle; m.title = "Middle"
    let b = MKPointAnnotation(); b.coordinate = back; b.title = "Back"
    return [f, m, b]
  }
}
