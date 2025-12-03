import Foundation
#if canImport(SwiftData)
import SwiftData
#endif

@MainActor
public extension ServiceRegistry {
    static func registerClubRecommender(modelContext: ModelContext) -> ClubRecommender {
        let adapter = SwiftDataShotAdapter(context: modelContext)
        let recommender = ClubRecommender()
        Task.detached { @MainActor in
            let shots = await adapter.fetchRecentShots()
            await recommender.replaceHistory(shots)
        }
        // Optionally store recommender in registry for app-wide access
        Self.shared.register(recommender)
        return recommender
    }
}
