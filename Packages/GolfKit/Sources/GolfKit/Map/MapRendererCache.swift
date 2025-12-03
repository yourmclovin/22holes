import MapKit

public final class MapRendererCache {
  private var circleRenderers: [String: MKCircleRenderer] = [:]
  private let lock = NSLock()

  public init() {}

  public func renderer(for circle: MKCircle, id: String) -> MKCircleRenderer {
    lock.lock(); defer { lock.unlock() }
    if let r = circleRenderers[id] { r.circle = circle; return r }
    let r = MKCircleRenderer(circle: circle)
    r.fillColor = .systemGreen.withAlphaComponent(0.12)
    r.strokeColor = .systemGreen
    r.lineWidth = 1.0
    circleRenderers[id] = r
    return r
  }

  public func removeRenderer(id: String) {
    lock.lock(); defer { lock.unlock() }
    circleRenderers[id] = nil
  }

  public func clear() {
    lock.lock(); defer { lock.unlock() }
    circleRenderers.removeAll(keepingCapacity: false)
  }
}
