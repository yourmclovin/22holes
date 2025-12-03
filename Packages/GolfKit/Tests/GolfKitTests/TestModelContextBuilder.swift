import Foundation
import SwiftData

/// Helper for tests to create an in-memory ModelContext
public enum TestModelContextBuilder {
  public static func makeModelContext(for models: [Any.Type]) async throws -> ModelContext {
    let schema = try await ModelSchemaBuilder.buildSchema(for: models)
    let container = try await ModelContainer(for: schema)
    return container.mainContext
  }
}
