import Foundation

public struct QueueItem: Codable, Equatable {
  public let id: UUID
  public let createdAt: Date
  public let payload: Data
  public var attempts: Int
  public var lastAttemptAt: Date?

  public init(id: UUID = UUID(), createdAt: Date = Date(), payload: Data, attempts: Int = 0) {
    self.id = id
    self.createdAt = createdAt
    self.payload = payload
    self.attempts = attempts
  }
}

public final class PersistentQueue {
  private let directory: URL
  private let indexFile: URL
  private var items: [QueueItem] = []
  private let queue = DispatchQueue(label: "com.yourmclovin.persistentqueue", qos: .utility)

  public init(appGroupID: String, subpath: String = "RoundSyncQueue") throws {
    #if os(iOS) || os(watchOS) || os(tvOS)
    guard let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) else {
      throw NSError(domain: "PersistentQueue", code: 1, userInfo: [NSLocalizedDescriptionKey: "App group container not available for \(appGroupID)"])
    }
    #else
    let container = FileManager.default.temporaryDirectory
    #endif
    self.directory = container.appendingPathComponent(subpath, isDirectory: true)
    self.indexFile = directory.appendingPathComponent("index.json")

    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    try loadIndex()
  }

  private func loadIndex() throws {
    queue.sync {
      if FileManager.default.fileExists(atPath: indexFile.path) {
        if let data = try? Data(contentsOf: indexFile), let decoded = try? JSONDecoder().decode([QueueItem].self, from: data) {
          self.items = decoded
        }
      } else {
        self.items = []
        try? saveIndex()
      }
    }
  }

  private func saveIndex() throws {
    let data = try JSONEncoder().encode(items)
    try data.write(to: indexFile, options: .atomic)
  }

  public func enqueue(_ item: QueueItem) throws {
    try queue.sync {
      items.append(item)
      try saveIndex()
      let itemURL = directory.appendingPathComponent(item.id.uuidString)
      try item.payload.write(to: itemURL, options: .atomic)
    }
  }

  public func peek() -> QueueItem? {
    return queue.sync { items.first }
  }

  public func dequeue() throws -> QueueItem? {
    return try queue.sync {
      guard !items.isEmpty else { return nil }
      let item = items.removeFirst()
      try saveIndex()
      let itemURL = directory.appendingPathComponent(item.id.uuidString)
      try? FileManager.default.removeItem(at: itemURL)
      return item
    }
  }

  public func markAttempt(_ id: UUID) throws {
    try queue.sync {
      guard let i = items.firstIndex(where: { $0.id == id }) else { return }
      items[i].attempts += 1
      items[i].lastAttemptAt = Date()
      try saveIndex()
    }
  }

  public func allItems() -> [QueueItem] {
    return queue.sync { items }
  }
}
