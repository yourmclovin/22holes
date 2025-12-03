import Foundation
import CoreHaptics

protocol HapticControlling {
  func playStableHit()
  func stop()
}

final class ARHaptics: HapticControlling {
  private var engine: CHHapticEngine?
  private var lastPlay: Date?
  private let cooldown: TimeInterval = 1.5

  init() {
    prepare()
  }

  private func prepare() {
    guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
    engine = try? CHHapticEngine()
    try? engine?.start()
  }

  func playStableHit() {
    guard let engine = engine else { return }
    // cooldown
    if let last = lastPlay, Date().timeIntervalSince(last) < cooldown { return }
    lastPlay = Date()
    // small strong transient
    let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8)
    let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.7)
    let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
    do {
      let pattern = try CHHapticPattern(events: [event], parameters: [])
      let player = try engine.makePlayer(with: pattern)
      try player.start(atTime: 0)
    } catch {
      // ignore
    }
  }

  func stop() {
    try? engine?.stop()
  }
}
