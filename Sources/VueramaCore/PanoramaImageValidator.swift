import Foundation

public struct PixelSize: Equatable, Sendable {
    public let width: Int
    public let height: Int

    public init(width: Int, height: Int) {
        self.width = width
        self.height = height
    }
}

public enum PanoramaValidationError: Error, Equatable, Sendable {
    case invalidDimensions
    case unsupportedAspectRatio(actual: Double)
}

public enum PanoramaImageValidator {
    /// Accepts equirectangular panoramas whose width-to-height ratio is close
    /// to 2:1. A small tolerance accommodates metadata rounding and padding.
    public static func validate(
        width: Int,
        height: Int,
        tolerance: Double = 0.01
    ) throws -> PixelSize {
        guard width > 0, height > 0 else {
            throw PanoramaValidationError.invalidDimensions
        }

        let ratio = Double(width) / Double(height)
        guard abs(ratio - 2.0) <= tolerance else {
            throw PanoramaValidationError.unsupportedAspectRatio(actual: ratio)
        }

        return PixelSize(width: width, height: height)
    }
}
