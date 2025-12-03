import Foundation
import ARKit

protocol ARSessionProviding: AnyObject {
  var session: ARSession { get }
}

extension ARView: ARSessionProviding {}
