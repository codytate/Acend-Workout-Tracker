import XCTest
@testable import Gainz

final class GainzTests: XCTestCase {
    func testPersistencePreviewCreatesContainer() throws {
        let controller = PersistenceController.preview
        XCTAssertNotNil(controller.container.viewContext)
    }

    func testExample() throws {
        XCTAssertTrue(true)
    }
}
