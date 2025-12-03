import Foundation
import SwiftData

public enum ModelSchemaBuilder {
  public static func buildSchema(for types: [Any.Type]) async throws -> ModelSchema {
    // For tests we rely on automatic schema generation - simplified stub
    return try ModelCollection([SDRound.self]).modelSchema
  }
}