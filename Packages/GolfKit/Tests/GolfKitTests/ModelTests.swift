import XCTest
@testable import GolfKit

final class ModelTests: XCTestCase {
  func testCourseEncodeDecode() throws {
    let hole = Hole(index: 1, par: 4, teeCoordinate: .init(lat: 1.3, lon: 103.8), greenCoordinate: .init(lat:1.3005, lon:103.8005), yardage: Yardage(middle: 420))
    let course = GolfCourse(name: "Test Course", location: .init(lat:1.3,lon:103.8), holes: [hole])
    let data = try JSONEncoder().encode(course)
    let decoded = try JSONDecoder().decode(GolfCourse.self, from: data)
    XCTAssertEqual(decoded.name, course.name)
    XCTAssertEqual(decoded.holes.count, 1)
  }
}
