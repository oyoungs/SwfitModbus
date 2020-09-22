import XCTest
@testable import Modbus

final class ModbusTests: XCTestCase {
    func testVersion() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertGreaterThanOrEqual(Version.major, UInt32(3))
        XCTAssertGreaterThanOrEqual(Version.minor, UInt32(1))
        XCTAssertGreaterThanOrEqual(Version.micro, UInt32(6))
        XCTAssertGreaterThanOrEqual(Version.string, "3.1.6")
       

    }

    static var allTests = [
        ("testVersion", testVersion),
    ]
}
