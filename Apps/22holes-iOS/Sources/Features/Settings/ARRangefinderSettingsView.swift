import SwiftUI

@MainActor
public struct ARRangefinderSettingsView: View {
  @AppStorage("ARRangefinderHapticsEnabled") private var hapticsEnabled: Bool = true
  @AppStorage("ARRangefinderSmoothingAlpha") private var smoothingAlpha: Double = 0.25

  public init() {}

  public var body: some View {
    Form {
      Section(header: Text("AR Rangefinder")) {
        Toggle("Enable Haptic Feedback", isOn: $hapticsEnabled)
        VStack(alignment: .leading) {
          Text("Smoothing (responsiveness)")
            .font(.subheadline)
            .foregroundColor(.secondary)
          Slider(value: $smoothingAlpha, in: 0.05...0.6, step: 0.01) {
            Text("Smoothing")
          } minimumValueLabel: {
            Text("Fast")
          } maximumValueLabel: {
            Text("Smooth")
          }
          Text(String(format: "Alpha: %.2f", smoothingAlpha))
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding(.top, 8)
      }
    }
    .navigationTitle("Rangefinder")
  }
}

#if DEBUG
struct ARRangefinderSettingsView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack { ARRangefinderSettingsView() }
  }
}
#endif
