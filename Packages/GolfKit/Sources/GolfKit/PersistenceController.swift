import Foundation
import SwiftUI
import CoreData

public final class PersistenceController {
  public static let shared = try! PersistenceController()

  public let container: NSPersistentContainer

  public init(inMemory: Bool = false) throws {
    let modelName = "GolfKitModel"
    guard let modelURL = Bundle.module.url(forResource: modelName, withExtension: "momd") else {
      // Fallback: create an empty container with no model - developers will add model later
      self.container = NSPersistentContainer(name: modelName)
      if inMemory {
        let desc = NSPersistentStoreDescription()
        desc.type = NSInMemoryStoreType
        self.container.persistentStoreDescriptions = [desc]
      }
      self.container.loadPersistentStores { _, error in
        if let err = error { fatalError("Unresolved error \(err)") }
      }
      return
    }

    let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) ?? NSManagedObjectModel()
    self.container = NSPersistentContainer(name: modelName, managedObjectModel: managedObjectModel)
    if inMemory {
      let desc = NSPersistentStoreDescription()
      desc.type = NSInMemoryStoreType
      self.container.persistentStoreDescriptions = [desc]
    }

    var loadError: Error?
    self.container.loadPersistentStores { _, error in
      if let e = error { loadError = e }
    }
    if let e = loadError { throw e }
    self.container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
  }

  public func newBackgroundContext() -> NSManagedObjectContext {
    return container.newBackgroundContext()
  }
}

public extension NSPersistentCloudKitContainer {
  // placeholder: if later migrating to CloudKit-enabled container
}
