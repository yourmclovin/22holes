import SwiftUI

@MainActor
public struct ARRangefinderSettingsView: View {
  @AppStorage("ARRangefinderHapticsEnabled") private var hapticsEnabled: Bool = true

  public init() {}

  public var body: some View {
    Form {
      Section(header: Text("AR Rangefinder")) {
        Toggle("Enable Haptic Feedback", isOn: $hapticsEnabled)
        HStack {
          Text("Smoothing")
          Spacer()
          Text("Medium").foregroundColor(.secondary)
        }
        .contentShape(Rectangle())
        .onTapGesture {
          // Could push a detail slider for alpha; left as scaffold
        }
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
