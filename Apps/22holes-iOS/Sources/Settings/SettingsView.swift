import SwiftUI
import SwiftData
import GolfKit

struct SettingsView: View {
  @Environment(\.modelContext) private var context
  @Query(kind: .single) private var settings: [SDAppSettings]

  var body: some View {
    Form {
      Toggle("Auto-detect haptics", isOn: bindingForHaptics())
    }
    .navigationTitle("Settings")
  }

  private func bindingForHaptics() -> Binding<Bool> {
    if let s = settings.first {
      return Binding(
        get: { s.enableAutoDetectHaptics },
        set: { new in
          Task {
            await context.perform {
              s.enableAutoDetectHaptics = new
            }
          }
        }
      )
    } else {
      // create default settings if missing
      return Binding(
        get: { true },
        set: { new in
          Task {
            await context.perform {
              let s = SDAppSettings(enableAutoDetectHaptics: new)
              context.insert(s)
            }
          }
        }
      )
    }
  }
}
