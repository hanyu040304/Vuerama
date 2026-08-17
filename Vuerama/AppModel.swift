import Foundation
import SwiftUI

struct ImportedPanorama: Identifiable, Equatable {
    let id: UUID
    let localURL: URL
    let displayName: String
    let pixelSize: PixelSize
}

@MainActor
final class AppModel: ObservableObject {
    static let immersiveSpaceID = "PanoramaSpace"

    @Published private(set) var panorama: ImportedPanorama?
    @Published private(set) var statusMessage = "请选择一张已经拼接完成的 2:1 全景照片。"
    @Published private(set) var importFailed = false
    @Published var viewingOffset = ViewingOffset()
    @Published var immersiveSpaceIsOpen = false

    var canEnterImmersiveSpace: Bool {
        panorama != nil && !immersiveSpaceIsOpen
    }

    func importPanorama(from sourceURL: URL) {
        let hasSecurityScope = sourceURL.startAccessingSecurityScopedResource()
        defer {
            if hasSecurityScope {
                sourceURL.stopAccessingSecurityScopedResource()
            }
        }

        do {
            let metadataSize = try PanoramaImageMetadataReader.pixelSize(at: sourceURL)
            let validatedSize = try PanoramaImageValidator.validate(
                width: metadataSize.width,
                height: metadataSize.height
            )
            let cachedURL = try cacheImportedFile(from: sourceURL)

            panorama = ImportedPanorama(
                id: UUID(),
                localURL: cachedURL,
                displayName: sourceURL.lastPathComponent,
                pixelSize: validatedSize
            )
            viewingOffset.reset()
            importFailed = false
            statusMessage = "已载入 \(sourceURL.lastPathComponent) · \(validatedSize.width) × \(validatedSize.height)"
        } catch PanoramaValidationError.invalidDimensions {
            presentImportFailure("无法读取图片尺寸，请换一张 JPEG、PNG 或 HEIC 图片。")
        } catch PanoramaValidationError.unsupportedAspectRatio {
            presentImportFailure("这张图片不是 2:1 等距柱状全景图。请选择宽度约为高度两倍的图片。")
        } catch {
            presentImportFailure(error.localizedDescription)
        }
    }

    func resetView() {
        viewingOffset.reset()
    }

    func reportFileImporterError(_ error: Error) {
        presentImportFailure("文件选择失败：\(error.localizedDescription)")
    }

    func didCloseImmersiveSpace() {
        immersiveSpaceIsOpen = false
    }

    private func presentImportFailure(_ message: String) {
        panorama = nil
        importFailed = true
        statusMessage = message
    }

    private func cacheImportedFile(from sourceURL: URL) throws -> URL {
        let fileManager = FileManager.default
        let cacheRoot = try fileManager.url(
            for: .cachesDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let importDirectory = cacheRoot.appendingPathComponent("ImportedPanoramas", isDirectory: true)
        try fileManager.createDirectory(
            at: importDirectory,
            withIntermediateDirectories: true
        )

        let fileExtension = sourceURL.pathExtension.isEmpty ? "image" : sourceURL.pathExtension
        let destination = importDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension(fileExtension)

        try fileManager.copyItem(at: sourceURL, to: destination)
        return destination
    }
}
