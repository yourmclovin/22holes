import Foundation
import SwiftData

public enum GolfKitModel {
  public static let models: [any Model.Type] = [SDCourse.self, SDHole.self, SDHazard.self, SDRound.self, SDShot.self, SDClub.self]
}

public final class SDPersistence {
  public let container: ModelContainer

  public init(inMemory: Bool = false) throws {
    if inMemory {
      self.container = try ModelContainer(for: GolfKitModel.models, configurations: .init(
        ModelConfiguration(inMemory: true)
      ))
    } else {
      self.container = try ModelContainer(for: GolfKitModel.models)
    }
  }

  public func newBackgroundContext() -> ModelContext {
    return container.mainContext
  }
}
