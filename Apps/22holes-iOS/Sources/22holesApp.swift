import SwiftUI
import GolfKit

@main
struct TwentyTwoHolesApp: App {
  @StateObject private var appState = AppState()

  var body: some Scene {
    WindowGroup {
      LandingView()
        .environment(\.modelContext, appState.persistence.container.mainContext)
        .environmentObject(appState)
    }
  }
}

final class AppState: ObservableObject {
  let persistence: SDPersistence

  init() {
    do {
      self.persistence = try SDPersistence(inMemory: false)
    } catch {
      self.persistence = try! SDPersistence(inMemory: true)
    }
  }
}
