import Foundation
import SwiftData

public struct SeedData {
  public static func seedSampleCourse(into context: ModelContext) throws {
    let holes = (1...9).map { i -> SDHole in
      let baseLat = 1.3000 + Double(i) * 0.0001
      let baseLon = 103.8000 + Double(i) * 0.0001
      return SDHole(index: i, par: 4, teeLatitude: baseLat, teeLongitude: baseLon, greenLatitude: baseLat + 0.00003, greenLongitude: baseLon + 0.00003, midYard: 120)
    }
    let course = SDCourse(name: "Singapore Demo Course", latitude: 1.3000, longitude: 103.8000, holes: holes)
    try context.performSync { context.insert(course) }
  }
}
