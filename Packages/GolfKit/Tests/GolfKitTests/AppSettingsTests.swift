import XCTest
import SwiftData
@testable import GolfKit

final class AppSettingsTests: XCTestCase {
  func testAppSettingsSaveAndFetch() throws {
    let persistence = try SDPersistence(inMemory: true)
    let ctx = persistence.container.mainContext

    let club = SDClub(name: "7 Iron", maxCarryMeters: 140)
    let settings = SDAppSettings(useMetric: false, shareLocation: true, clubBag: [club])

    try ctx.performSync { ctx.insert(settings) }

    let fetched = try ctx.fetch(SDAppSettings.self)
    XCTAssertEqual(fetched.count, 1)
    XCTAssertEqual(fetched.first?.useMetric, false)
    XCTAssertEqual(fetched.first?.shareLocation, true)
    XCTAssertEqual(fetched.first?.clubBag.first?.name, "7 Iron")
  }
}
