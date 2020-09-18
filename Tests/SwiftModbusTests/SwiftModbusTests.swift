import XCTest
@testable import SwiftModbus

final class SwiftModbusTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Version.major, UInt32(3))
        XCTAssertEqual(Version.minor, UInt32(0))
        XCTAssertEqual(Version.micro, UInt32(6))
        XCTAssertEqual(Version.string, "3.0.6")

    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
