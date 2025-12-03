import SwiftUI
import GolfKit

struct SettingsView: View {
  @Environment(\.modelContext) var context
  @Query(sort: []) var settings: [SDAppSettings]

  var body: some View {
    Form {
      Toggle("Use Metric", isOn: bindingFor { $0.useMetric })
      Toggle("Share Location", isOn: bindingFor { $0.shareLocation })
      Section("Clubs") {
        if let bag = settings.first?.clubBag, !bag.isEmpty {
          ForEach(bag, id: \.id) { club in
            Text(club.name)
          }
        } else {
          Text("No clubs configured")
        }
      }
    }
    .navigationTitle("Settings")
    .onAppear { ensureSettings() }
  }

  private func ensureSettings() {
    guard settings.isEmpty else { return }
    let s = SDAppSettings()
    try? context.performSync { context.insert(s) }
  }

  private func bindingFor(_ keyPath: @escaping (SDAppSettings) -> Bool) -> Binding<Bool> {
    Binding(get: {
      settings.first.map { keyPath($0) } ?? false
    }, set: { newValue in
      guard let s = settings.first else { return }
      try? context.performSync { 
        if keyPath === SDAppSettings.useMetric as? (SDAppSettings) -> Bool { s.useMetric = newValue }
      }
    })
  }
}
