import XCTest
@testable import VueramaCore

final class PanoramaImageValidatorTests: XCTestCase {
    func testExactTwoToOneImageIsAccepted() throws {
        let size = try PanoramaImageValidator.validate(width: 8_192, height: 4_096)

        XCTAssertEqual(size, PixelSize(width: 8_192, height: 4_096))
    }

    func testSmallMetadataRoundingDifferenceIsAccepted() throws {
        let size = try PanoramaImageValidator.validate(width: 6_000, height: 3_008)

        XCTAssertEqual(size, PixelSize(width: 6_000, height: 3_008))
    }

    func testOrdinaryPhotoIsRejected() {
        XCTAssertThrowsError(
            try PanoramaImageValidator.validate(width: 4_032, height: 3_024)
        ) { error in
            guard case let PanoramaValidationError.unsupportedAspectRatio(actualRatio) = error else {
                return XCTFail("Expected unsupportedAspectRatio, got \(error)")
            }

            XCTAssertEqual(actualRatio, 4_032.0 / 3_024.0, accuracy: 0.000_001)
        }
    }

    func testZeroDimensionIsRejectedBeforeComputingRatio() {
        XCTAssertThrowsError(
            try PanoramaImageValidator.validate(width: 0, height: 2_048)
        ) { error in
            XCTAssertEqual(error as? PanoramaValidationError, .invalidDimensions)
        }
    }
}
