import Foundation
import CoreLocation

public struct ShotRecord: Codable, Identifiable {
    public let id: UUID
    public let club: String
    public let distanceMeters: Double
    public let windSpeedMps: Double
    public let windDirDeg: Double
    public let lieType: String?
    public let timestamp: Date
    public init(id: UUID = .init(), club: String, distanceMeters: Double, windSpeedMps: Double = 0, windDirDeg: Double = 0, lieType: String? = nil, timestamp: Date = .init()) {
        self.id = id; self.club = club; self.distanceMeters = distanceMeters; self.windSpeedMps = windSpeedMps; self.windDirDeg = windDirDeg; self.lieType = lieType; self.timestamp = timestamp
    }
}

fileprivate struct FeatureVector {
    let distance: Double
    let wind: Double
    let lieFairway: Double
    init(from record: ShotRecord) {
        distance = record.distanceMeters / 300.0
        wind = record.windSpeedMps / 20.0
        lieFairway = (record.lieType == "fairway") ? 1.0 : 0.0
    }
    func distanceSquared(to other: FeatureVector, weights: SIMD3<Double>) -> Double {
        let dx = (distance - other.distance) * weights[0]
        let dw = (wind - other.wind) * weights[1]
        let dl = (lieFairway - other.lieFairway) * weights[2]
        return dx*dx + dw*dw + dl*dl
    }
}

@MainActor
public actor ClubRecommender {
    public typealias Candidate = (club: String, score: Double)

    private var history: [ShotRecord]
    private let k: Int
    private let weights: SIMD3<Double>

    public init(history: [ShotRecord] = [], k: Int = 10, weights: SIMD3<Double> = SIMD3(1.0, 0.7, 0.6)) {
        self.history = history
        self.k = k
        self.weights = weights
    }

    public func replaceHistory(_ new: [ShotRecord]) async {
        self.history = new
    }

    public func add(_ shot: ShotRecord) async {
        history.append(shot)
        if history.count > 2000 { history.removeFirst(history.count - 2000) }
    }

    public func recommend(forDistance meters: Double, windMps: Double = 0, lie: String? = nil, limit: Int = 3) async -> [Candidate] {
        guard !history.isEmpty else { return [] }
        let q = ShotRecord(club: "", distanceMeters: meters, windSpeedMps: windMps, windDirDeg: 0, lieType: lie)
        let qfv = FeatureVector(from: q)
        var scored: [(club: String, dist: Double)] = []
        scored.reserveCapacity(history.count)
        for h in history {
            let fv = FeatureVector(from: h)
            let d2 = fv.distanceSquared(to: qfv, weights: weights)
            scored.append((club: h.club, dist: d2))
        }
        scored.sort { $0.dist < $1.dist }
        let nearest = scored.prefix(k)
        var agg: [String: Double] = [:]
        for item in nearest {
            let weight = 1.0 / (0.001 + item.dist)
            agg[item.club, default: 0.0] += weight
        }
        let candidates = agg.map { (club: $0.key, score: $0.value) }
            .sorted { $0.score > $1.score }
            .prefix(limit)
        return Array(candidates)
    }

    // Return a representative historic ShotRecord for a given club nearest to the query features.
    // Useful for "why" explanations in the UI.
    public func representativeExample(forClub club: String, forDistance meters: Double, windMps: Double = 0, lie: String? = nil) async -> ShotRecord? {
        guard !history.isEmpty else { return nil }
        let q = ShotRecord(club: club, distanceMeters: meters, windSpeedMps: windMps, windDirDeg: 0, lieType: lie)
        let qfv = FeatureVector(from: q)
        var best: (shot: ShotRecord, dist: Double)? = nil
        for h in history where h.club == club {
            let fv = FeatureVector(from: h)
            let d2 = fv.distanceSquared(to: qfv, weights: weights)
            if let b = best {
                if d2 < b.dist { best = (shot: h, dist: d2) }
            } else {
                best = (shot: h, dist: d2)
            }
        }
        return best?.shot
    }
}
