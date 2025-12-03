import SwiftUI

@main
struct TwentyTwoHolesWatchApp: App {
  var body: some Scene {
    WindowGroup {
      WatchEntryView()
    }
  }
}

struct WatchEntryView: View {
  var body: some View {
    VStack {
      Text("22holes")
        .font(.headline)
      Text("Yardage: -- m")
      Button("Start") { }
    }
    .padding()
  }
}
