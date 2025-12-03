import SwiftUI
import RealityKit
import ARKit
import Combine
import CoreHaptics

@MainActor
public struct ARRangefinderView: UIViewControllerRepresentable {
  @Binding var isRunning: Bool
  public var playsLike: (Double) -> Double = { $0 }

  public func makeUIViewController(context: Context) -> ARVC {
    let vc = ARVC()
    vc.playsLike = playsLike
    vc.hapticsController = ARHaptics()
    return vc
  }

  public func updateUIViewController(_ vc: ARVC, context: Context) {
    isRunning ? vc.startSession() : vc.pauseSession()
  }

  public init(isRunning: Binding<Bool>, playsLike: @escaping (Double) -> Double = { $0 }) {
    self._isRunning = isRunning
    self.playsLike = playsLike
  }
}

final class ARVC: UIViewController, ARSessionDelegate {
  var arView = ARView(frame: .zero)
  private var targetAnchor: AnchorEntity?
  private var smoothing: ExponentialMovingAverage
  private var cancellables = Set<AnyCancellable>()
  var playsLike: (Double) -> Double = { $0 }
  private var lastStableTime: Date?
  private var observers: [Any] = []
  var hapticsController: HapticControlling?

  private var hapticsEnabled: Bool {
    UserDefaults.standard.bool(forKey: "ARRangefinderHapticsEnabled")
  }

  private var smoothingAlpha: Double {
    let v = UserDefaults.standard.double(forKey: "ARRangefinderSmoothingAlpha")
    return v == 0 ? 0.25 : v
  }

  init() {
    self.smoothing = ExponentialMovingAverage(alpha: UserDefaults.standard.double(forKey: "ARRangefinderSmoothingAlpha") == 0 ? 0.25 : UserDefaults.standard.double(forKey: "ARRangefinderSmoothingAlpha"))
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  override func viewDidLoad() {
    super.viewDidLoad()
    arView.automaticallyConfigureSession = false
    view.addSubview(arView)
    arView.frame = view.bounds
    arView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
    arView.addGestureRecognizer(tap)
    prepareHaptics()

    // Observe changes to haptics and smoothing settings
    let center = NotificationCenter.default
    let obs1 = center.addObserver(forName: UserDefaults.didChangeNotification, object: nil, queue: .main) { [weak self] _ in
      guard let self = self else { return }
      if self.hapticsEnabled { self.hapticsController?.playStableHit() }
      // update smoothing alpha at runtime
      let alpha = self.smoothingAlpha
      self.smoothing = ExponentialMovingAverage(alpha: alpha)
    }
    observers.append(obs1)
  }

  func startSession() {
    let config = ARWorldTrackingConfiguration()
    config.planeDetection = [.horizontal]
    arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
    arView.session.delegate = self
  }

  func pauseSession() {
    arView.session.pause()
    arView.session.delegate = nil
    hapticsController?.stop()
  }

  @objc private func handleTap(_ g: UITapGestureRecognizer) {
    let p = g.location(in: arView)
    if let result = arView.raycast(from: p, allowing: .estimatedPlane, alignment: .any).first {
      placeTarget(at: result.worldTransform)
    } else if let cam = arView.session.currentFrame?.camera.transform {
      var t = cam
      t.columns.3.z -= 2.0
      placeTarget(at: t)
    }
  }

  private func placeTarget(at transform: simd_float4x4) {
    targetAnchor?.removeFromParent()
    let anchor = AnchorEntity(world: transform)
    let sphere = ModelEntity(mesh: .generateSphere(radius: 0.03), materials: [SimpleMaterial(color: .systemGreen, isMetallic: false)])
    anchor.addChild(sphere)
    arView.scene.addAnchor(anchor)
    targetAnchor = anchor
    smoothing.reset()
    lastStableTime = nil
  }

  func session(_ session: ARSession, didUpdate frame: ARFrame) {
    guard let target = targetAnchor else { return }
    let cameraTransform = frame.camera.transform
    let camPos = SIMD3<Float>(cameraTransform.columns.3.x, cameraTransform.columns.3.y, cameraTransform.columns.3.z)
    let targetPos = target.position(relativeTo: nil)
    let dist = simd_distance(camPos, targetPos)
    let meters = Double(dist)
    let smoothed = smoothing.update(meters)
    let plays = playsLike(smoothed)
    let accuracy = frame.camera.trackingState
    DispatchQueue.main.async { [weak self] in
      NotificationCenter.default.post(name: .ARRangefinderDidUpdate, object: nil, userInfo: ["meters": smoothed, "playsLike": plays, "trackingState": accuracy])
      self?.maybeHapticIfStable(current: smoothed)
    }
  }

  private func maybeHapticIfStable(current: Double) {
    guard hapticsEnabled else { return }
    let threshold = 0.3
    if let last = smoothing.lastValue, abs(current - last) < threshold {
      if lastStableTime == nil { lastStableTime = Date() }
      if let start = lastStableTime, Date().timeIntervalSince(start) > 1.2 {
        hapticsController?.playStableHit()
        lastStableTime = Date()
      }
    } else {
      lastStableTime = nil
    }
  }

  private func prepareHaptics() {
    if hapticsEnabled { hapticsController = ARHaptics() }
  }

  deinit {
    for obs in observers { NotificationCenter.default.removeObserver(obs) }
  }
}
