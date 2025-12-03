import Foundation
import SwiftData
import CoreLocation

@Model
public final class SDClub: Codable, Identifiable {
  @Attribute(.unique) public var id: UUID
  public var name: String
  public var maxCarryMeters: Double?

  public init(id: UUID = .init(), name: String, maxCarryMeters: Double? = nil) {
    self.id = id
    self.name = name
    self.maxCarryMeters = maxCarryMeters
  }
}

@Model
public final class SDShot: Codable, Identifiable {
  @Attribute(.unique) public var id: UUID
  public var clubID: UUID?
  public var latitude: Double
  public var longitude: Double
  public var timestamp: Date

  public init(id: UUID = .init(), clubID: UUID? = nil, latitude: Double, longitude: Double, timestamp: Date = .init()) {
    self.id = id; self.clubID = clubID; self.latitude = latitude; self.longitude = longitude; self.timestamp = timestamp
  }
}

@Model
public final class SDRound: Codable, Identifiable {
  @Attribute(.unique) public var id: UUID
  public var courseID: UUID?
  public var date: Date
  public var shots: [SDShot]
  public var scoreByHole: [Int: Int]

  public init(id: UUID = .init(), courseID: UUID? = nil, date: Date = .init(), shots: [SDShot] = [], scoreByHole: [Int: Int] = [:]) {
    self.id = id; self.courseID = courseID; self.date = date; self.shots = shots; self.scoreByHole = scoreByHole
  }
}

@Model
public final class SDHazard: Codable, Identifiable {
  @Attribute(.unique) public var id: UUID
  public enum Kind: String, Codable { case water, bunker, outOfBounds, trees, other }
  public var kind: Kind
  public var latitude: Double
  public var longitude: Double

  public init(id: UUID = .init(), kind: Kind, latitude: Double, longitude: Double) {
    self.id = id; self.kind = kind; self.latitude = latitude; self.longitude = longitude
  }
}

@Model
public final class SDHole: Codable, Identifiable {
  @Attribute(.unique) public var id: UUID
  public var index: Int
  public var par: Int
  public var teeLatitude: Double
  public var teeLongitude: Double
  public var greenLatitude: Double
  public var greenLongitude: Double
  public var frontYard: Double?
  public var midYard: Double
  public var backYard: Double?
  public var hazards: [SDHazard]

  public init(id: UUID = .init(), index: Int, par: Int, teeLatitude: Double, teeLongitude: Double, greenLatitude: Double, greenLongitude: Double, frontYard: Double? = nil, midYard: Double, backYard: Double? = nil, hazards: [SDHazard] = []) {
    self.id = id; self.index = index; self.par = par; self.teeLatitude = teeLatitude; self.teeLongitude = teeLongitude; self.greenLatitude = greenLatitude; self.greenLongitude = greenLongitude; self.frontYard = frontYard; self.midYard = midYard; self.backYard = backYard; self.hazards = hazards
  }
}

@Model
public final class SDCourse: Codable, Identifiable {
  @Attribute(.unique) public var id: UUID
  public var name: String
  public var latitude: Double
  public var longitude: Double
  public var holes: [SDHole]

  public init(id: UUID = .init(), name: String, latitude: Double, longitude: Double, holes: [SDHole] = []) {
    self.id = id; self.name = name; self.latitude = latitude; self.longitude = longitude; self.holes = holes
  }
}
