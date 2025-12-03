import Foundation
#if canImport(SwiftData)
import SwiftData
#endif

@MainActor
public actor ShotRecorder: ObservableObject {
    public struct ShotOp {
        public let record: ShotRecordModel
        public init(record: ShotRecordModel) { self.record = record }
    }

    @Published private(set) public var lastOperation: ShotOp? = nil

    private let context: ModelContext?
    private var undoStack: [ShotRecordModel] = []

    public init(context: ModelContext? = nil) {
        self.context = context
    }

    public func recordShot(_ shot: ShotRecordModel) async throws {
        // persist to SwiftData if available
        if let ctx = context {
            let entity = Shot() // assumes SwiftData entity `Shot` exists
            entity.id = shot.id
            entity.club = shot.club
            entity.distanceMeters = shot.distanceMeters
            entity.windSpeedMps = shot.windSpeedMps
            entity.windDirDeg = shot.windDirDeg
            entity.lieType = shot.lieType
            entity.latitude = shot.latitude as NSNumber?
            entity.longitude = shot.longitude as NSNumber?
            entity.holeID = shot.holeID as UUID?
            entity.timestamp = shot.timestamp
            try ctx.save()
        }
        undoStack.append(shot)
        lastOperation = ShotOp(record: shot)
        // post notification for UI sync
        NotificationCenter.default.post(name: .shotRecorderDidAdd, object: shot)
    }

    public func undoLastShot() async throws {
        guard let last = undoStack.popLast() else { return }
        // delete from SwiftData if present
        if let ctx = context {
            let request = FetchDescriptor<Shot>(predicate: #Predicate<Shot> { $0.id == last.id })
            let results = try ctx.fetch(request)
            for r in results { ctx.delete(r) }
            try ctx.save()
        }
        lastOperation = ShotOp(record: last)
        NotificationCenter.default.post(name: .shotRecorderDidUndo, object: last)
    }

    public func fetchAllShots(limit: Int = 2000) async -> [ShotRecordModel] {
        if let ctx = context {
            let request = FetchDescriptor<Shot>(sortBy: [\.-Shot.timestamp], limit: limit)
            do {
                let results = try ctx.fetch(request)
                return results.map { s in
                    ShotRecordModel(id: s.id ?? UUID(), club: s.club ?? "Unknown", distanceMeters: s.distanceMeters, windSpeedMps: s.windSpeedMps, windDirDeg: s.windDirDeg, lieType: s.lieType, latitude: s.latitude?.doubleValue, longitude: s.longitude?.doubleValue, holeID: s.holeID, timestamp: s.timestamp ?? Date())
                }
            } catch {
                return []
            }
        }
        return []
    }
}

public extension Notification.Name {
    static let shotRecorderDidAdd = Notification.Name("ShotRecorderDidAdd")
    static let shotRecorderDidUndo = Notification.Name("ShotRecorderDidUndo")
}
