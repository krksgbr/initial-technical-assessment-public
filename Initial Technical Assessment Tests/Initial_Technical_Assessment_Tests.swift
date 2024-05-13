@testable import Initial_Technical_Assessment
import XCTest

final class Initial_Technical_Assessment_Tests: XCTestCase {
    func testComicViewCalculateColor() throws {
        let image = UIImage(imageLiteralResourceName: "TestImage")
        let options = XCTMeasureOptions.default
        options.iterationCount = 100
        measure(options: options) {
            let _ = image.blurAndAverageColor(blurRadius: 10)
        }
    }
}
