import XCTest
import SwiftData
@testable import GolfKit

final class SwiftDataPersistenceTests: XCTestCase {
  func testSaveAndFetchCourse() throws {
    let persistence = try SDPersistence(inMemory: true)
    let ctx = persistence.container.mainContext

    let hole = SDHole(index: 1, par: 4, teeLatitude: 1.3, teeLongitude: 103.8, greenLatitude: 1.3005, greenLongitude: 103.8005, midYard: 420)
    let course = SDCourse(name: "Test Course", latitude: 1.3, longitude: 103.8, holes: [hole])

    try ctx.performSync { ctx.insert(course) }

    let fetch = try ctx.fetch(SDCourse.self)
    XCTAssertEqual(fetch.count, 1)
    XCTAssertEqual(fetch.first?.name, "Test Course")
  }
}
