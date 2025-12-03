import Foundation
import SwiftUI
import CoreLocation

// Simple, testable value types + SwiftData-ready annotations can be added later

public struct Coordinate: Codable, Hashable, Sendable {
  public let latitude: Double
  public let longitude: Double

  public init(lat: Double, lon: Double) {
    self.latitude = lat
    self.longitude = lon
  }

  public var clCoordinate: CLLocationCoordinate2D { CLLocationCoordinate2D(latitude: latitude, longitude: longitude) }
}

public struct Club: Identifiable, Codable, Hashable, Sendable {
  public let id: UUID
  public var name: String
  public var maxCarryMeters: Double?
  public init(id: UUID = .init(), name: String, maxCarryMeters: Double? = nil) {
    self.id = id; self.name = name; self.maxCarryMeters = maxCarryMeters
  }
}

public struct ClubBag: Codable, Sendable {
  public var clubs: [Club]
  public init(clubs: [Club] = []) { self.clubs = clubs }
}

public struct Yardage: Codable, Hashable, Sendable {
  public var front: Double?
  public var middle: Double
  public var back: Double?
  public init(front: Double? = nil, middle: Double, back: Double? = nil) { self.front = front; self.middle = middle; self.back = back }
}

public struct Hazard: Codable, Hashable, Sendable {
  public enum Kind: String, Codable { case water, bunker, outOfBounds, trees, other }
  public var id: UUID = .init()
  public var kind: Kind
  public var coordinate: Coordinate
}

public struct Hole: Codable, Hashable, Sendable {
  public var id: UUID
  public var index: Int
  public var par: Int
  public var teeCoordinate: Coordinate
  public var greenCoordinate: Coordinate
  public var yardage: Yardage
  public var hazards: [Hazard]
  public init(id: UUID = .init(), index: Int, par: Int, teeCoordinate: Coordinate, greenCoordinate: Coordinate, yardage: Yardage, hazards: [Hazard] = []) {
    self.id = id; self.index = index; self.par = par; self.teeCoordinate = teeCoordinate; self.greenCoordinate = greenCoordinate; self.yardage = yardage; self.hazards = hazards
  }
}

public struct GolfCourse: Codable, Hashable, Sendable {
  public var id: UUID
  public var name: String
  public var location: Coordinate
  public var holes: [Hole]
  public init(id: UUID = .init(), name: String, location: Coordinate, holes: [Hole] = []) { self.id = id; self.name = name; self.location = location; self.holes = holes }
}

public struct Shot: Codable, Hashable, Sendable {
  public var id: UUID
  public var clubID: UUID?
  public var location: Coordinate
  public var timestamp: Date
  public init(id: UUID = .init(), clubID: UUID? = nil, location: Coordinate, timestamp: Date = .init()) { self.id = id; self.clubID = clubID; self.location = location; self.timestamp = timestamp }
}

public struct RoundModel: Codable, Hashable, Sendable {
  public var id: UUID
  public var courseID: UUID?
  public var date: Date
  public var shots: [Shot]
  public var scoreByHole: [Int: Int]
  public init(id: UUID = .init(), courseID: UUID? = nil, date: Date = .init(), shots: [Shot] = [], scoreByHole: [Int: Int] = [:]) { self.id = id; self.courseID = courseID; self.date = date; self.shots = shots; self.scoreByHole = scoreByHole }
}
