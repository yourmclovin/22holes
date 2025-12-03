import Foundation
import CoreLocation

public struct ShotRecordModel: Codable, Identifiable {
    public let id: UUID
    public let club: String
    public let distanceMeters: Double
    public let windSpeedMps: Double
    public let windDirDeg: Double
    public let lieType: String?
    public let latitude: Double?
    public let longitude: Double?
    public let holeID: UUID?
    public let timestamp: Date

    public init(id: UUID = UUID(), club: String, distanceMeters: Double, windSpeedMps: Double = 0, windDirDeg: Double = 0, lieType: String? = nil, latitude: Double? = nil, longitude: Double? = nil, holeID: UUID? = nil, timestamp: Date = Date()) {
        self.id = id
        self.club = club
        self.distanceMeters = distanceMeters
        self.windSpeedMps = windSpeedMps
        self.windDirDeg = windDirDeg
        self.lieType = lieType
        self.latitude = latitude
        self.longitude = longitude
        self.holeID = holeID
        self.timestamp = timestamp
    }
}
