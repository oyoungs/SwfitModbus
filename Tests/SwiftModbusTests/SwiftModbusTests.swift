import XCTest
@testable import Modbus

final class SwiftModbusTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Version.major, UInt32(3))
        XCTAssertEqual(Version.minor, UInt32(1))
        XCTAssertEqual(Version.micro, UInt32(6))
        XCTAssertEqual(Version.string, "3.1.6")
        
        let bytes: [UInt8] = [0, 1, 2, 3]
        var buffer = [UInt8](repeating: 0, count: 4)
        
        let bufferPointer = buffer.withUnsafeMutableBufferPointer { $0 }
        

        for i in 0 ..< bufferPointer.count {
            bufferPointer[i] = UInt8(i)
        }
        
        
        XCTAssertEqual(buffer, bytes)
        
       

    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
