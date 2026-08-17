import XCTest
@testable import VueramaCore

final class ViewingOffsetTests: XCTestCase {
    func testHorizontalDragAccumulatesYawAndWrapsItIntoSignedPiRange() {
        var offset = ViewingOffset(yaw: 3.0, pitch: 0)

        offset.applyDrag(horizontal: 100, vertical: 0, sensitivity: 0.004)

        XCTAssertEqual(offset.yaw, -2.883_185_4, accuracy: 0.000_001)
        XCTAssertEqual(offset.pitch, 0, accuracy: 0.000_001)
    }

    func testVerticalDragClampsPitchInsteadOfTurningUpsideDown() {
        var offset = ViewingOffset()

        offset.applyDrag(horizontal: 0, vertical: -10_000, sensitivity: 0.004)

        XCTAssertEqual(offset.pitch, ViewingOffset.maximumPitch, accuracy: 0.000_001)
    }

    func testOppositeVerticalDragClampsAtNegativeMaximumPitch() {
        var offset = ViewingOffset()

        offset.applyDrag(horizontal: 0, vertical: 10_000, sensitivity: 0.004)

        XCTAssertEqual(offset.pitch, -ViewingOffset.maximumPitch, accuracy: 0.000_001)
    }

    func testResetReturnsToCameraAuthoredFrontDirection() {
        var offset = ViewingOffset(yaw: 1.25, pitch: -0.4)

        offset.reset()

        XCTAssertEqual(offset, ViewingOffset())
    }
}
