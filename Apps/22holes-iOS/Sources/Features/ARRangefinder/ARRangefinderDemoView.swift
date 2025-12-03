import SwiftUI

@MainActor
public struct ARRangefinderDemoView: View {
  @State private var running = false
  @State private var meters: Double?
  @State private var playsLike: Double?

  public init() {}

  public var body: some View {
    VStack(spacing: 16) {
      ZStack {
        Color.black.opacity(0.02).edgesIgnoringSafeArea(.all)
        VStack {
          if let m = meters {
            Text(String(format: "%.1f m", m))
              .font(.system(size: 48, weight: .bold, design: .rounded))
              .foregroundColor(.green)
          } else {
            Text("Tap to place target in AR")
              .font(.headline)
              .foregroundColor(.secondary)
          }

          if let p = playsLike {
            Text(String(format: "Plays‑Like: %.0f m", p))
              .font(.subheadline)
              .foregroundColor(.primary)
          }

          Spacer()

          Toggle(isOn: $running.animation()) {
            Text(running ? "Stop AR" : "Start AR")
          }
          .padding()
          .onChange(of: running) { new in
            // The parent SwiftUI should present ARRangefinderView elsewhere; this demo demonstrates state toggling.
            NotificationCenter.default.post(name: .ARRangefinderToggleRequested, object: nil, userInfo: ["running": new])
          }
        }
        .padding(24)
      }
    }
    .onAppear(perform: subscribe)
    .onDisappear(perform: unsubscribe)
  }

  private func subscribe() {
    NotificationCenter.default.addObserver(forName: .ARRangefinderDidUpdate, object: nil, queue: .main) { n in
      if let m = n.userInfo?["meters"] as? Double {
        self.meters = m
      }
      if let p = n.userInfo?["playsLike"] as? Double {
        self.playsLike = p
      }
    }
  }

  private func unsubscribe() {
    NotificationCenter.default.removeObserver(self, name: .ARRangefinderDidUpdate, object: nil)
  }
}

extension Notification.Name { static let ARRangefinderToggleRequested = Notification.Name("ARRangefinderToggleRequested") }
