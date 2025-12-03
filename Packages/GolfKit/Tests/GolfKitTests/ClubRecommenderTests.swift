import XCTest
@testable import GolfKit

final class ClubRecommenderTests: XCTestCase {
    func testRecommendPicksNearestCluster() async {
        let history: [ShotRecord] = [
            // Cluster around 140m -> 7I
            ShotRecord(club: "7I", distanceMeters: 138),
            ShotRecord(club: "7I", distanceMeters: 142),
            ShotRecord(club: "7I", distanceMeters: 135),
            // Cluster around 150m -> 6I
            ShotRecord(club: "6I", distanceMeters: 148),
            ShotRecord(club: "6I", distanceMeters: 152),
            // Outlier driver
            ShotRecord(club: "Driver", distanceMeters: 230)
        ]

        let recommender = ClubRecommender(history: history, k: 5)
        let results = await recommender.recommend(forDistance: 140, windMps: 0, lie: "fairway", limit: 2)
        XCTAssertFalse(results.isEmpty)
        // top suggestion should be 7I
        XCTAssertEqual(results.first?.club, "7I")
    }

    func testRepresentativeExampleReturnsNearestHistoric() async {
        let history: [ShotRecord] = [
            ShotRecord(club: "7I", distanceMeters: 120),
            ShotRecord(club: "7I", distanceMeters: 140),
            ShotRecord(club: "7I", distanceMeters: 160)
        ]
        let recommender = ClubRecommender(history: history)
        let example = await recommender.representativeExample(forClub: "7I", forDistance: 145)
        XCTAssertNotNil(example)
        XCTAssertEqual(example?.club, "7I")
        // nearest to 145 should be 140
        XCTAssertEqual(Int(example!.distanceMeters), 140)
    }
}
