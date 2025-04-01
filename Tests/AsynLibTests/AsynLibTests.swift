import XCTest
@testable import AsynLib

final class AsynLibTests: XCTestCase {
    
    func testSayHello() {
        let pakage = MyPakage()
        XCTAssertEqual(pakage.sayHello(), "Hello world!")
    }
    
}
