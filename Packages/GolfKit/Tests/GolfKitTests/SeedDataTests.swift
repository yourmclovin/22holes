import XCTest
import SwiftData
@testable import GolfKit

final class SeedDataTests: XCTestCase {
  func testSeedSampleCourseCreatesCourse() throws {
    let persistence = try SDPersistence(inMemory: true)
    let ctx = persistence.container.mainContext

    try SeedData.seedSampleCourse(into: ctx)

    let courses = try ctx.fetch(SDCourse.self)
    XCTAssertEqual(courses.count, 1)
    let course = courses.first!
    XCTAssertEqual(course.name, "Singapore Demo Course")
    XCTAssertEqual(course.holes.count, 9)
  }
}
