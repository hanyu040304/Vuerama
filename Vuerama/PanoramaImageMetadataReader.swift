import Foundation
import ImageIO

enum PanoramaMetadataError: LocalizedError {
    case unreadableImage
    case missingDimensions

    var errorDescription: String? {
        switch self {
        case .unreadableImage:
            return "无法打开所选图片。"
        case .missingDimensions:
            return "图片文件没有可读取的像素尺寸。"
        }
    }
}

enum PanoramaImageMetadataReader {
    static func pixelSize(at url: URL) throws -> PixelSize {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            throw PanoramaMetadataError.unreadableImage
        }
        guard
            let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil)
                as? [CFString: Any],
            let width = (properties[kCGImagePropertyPixelWidth] as? NSNumber)?.intValue,
            let height = (properties[kCGImagePropertyPixelHeight] as? NSNumber)?.intValue
        else {
            throw PanoramaMetadataError.missingDimensions
        }

        return PixelSize(width: width, height: height)
    }
}
