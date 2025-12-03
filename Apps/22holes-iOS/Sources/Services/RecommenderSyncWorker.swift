import Foundation
#if canImport(SwiftData)
import SwiftData
#endif

@MainActor
public final class RecommenderSyncWorker: ObservableObject {
  private let recommender: ClubRecommender
  private let adapter: SwiftDataShotAdapter
  private var observation: ObservationToken?

  public init(recommender: ClubRecommender, context: ModelContext) {
    self.recommender = recommender
    self.adapter = SwiftDataShotAdapter(context: context)
    // initial sync
    Task { @MainActor in
      let shots = await adapter.fetchRecentShots()
      await recommender.replaceHistory(shots)
    }
    // Observe context changes to keep history fresh
    if #available(iOS 17.0, *) {
      observation = context.registerChangeObserver { [weak self] changes in
        guard let self = self else { return }
        Task { @MainActor in
          let shots = await self.adapter.fetchRecentShots()
          await self.recommender.replaceHistory(shots)
        }
      }
    }
  }

  deinit {
    observation?.invalidate()
  }
}

// Minimal observation token wrapper to avoid exposing internals
public final class ObservationToken {
  private let cancel: () -> Void
  init(cancel: @escaping () -> Void) { self.cancel = cancel }
  func invalidate() { cancel() }
}

#endif
