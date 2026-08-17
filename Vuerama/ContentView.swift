import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    @State private var showsFileImporter = false
    @State private var isOpeningImmersiveSpace = false

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "view.360")
                .font(.system(size: 58, weight: .medium))
                .foregroundStyle(.tint)

            VStack(spacing: 8) {
                Text("Vuerama")
                    .font(.largeTitle.bold())
                Text("2:1 全景照片空间播放器 Demo")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }

            GroupBox {
                HStack(spacing: 12) {
                    Image(systemName: model.importFailed ? "exclamationmark.triangle.fill" : "photo")
                        .foregroundStyle(model.importFailed ? Color.orange : Color.secondary)
                    Text(model.statusMessage)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(6)
            }

            if model.immersiveSpaceIsOpen {
                HStack(spacing: 16) {
                    Button {
                        model.resetView()
                    } label: {
                        Label("回正", systemImage: "scope")
                    }

                    Button(role: .cancel) {
                        Task {
                            await dismissImmersiveSpace()
                            model.didCloseImmersiveSpace()
                        }
                    } label: {
                        Label("退出全景", systemImage: "xmark")
                    }
                }
                .controlSize(.large)
            } else {
                HStack(spacing: 16) {
                    Button {
                        showsFileImporter = true
                    } label: {
                        Label("选择全景照片", systemImage: "folder")
                    }

                    Button {
                        enterImmersiveSpace()
                    } label: {
                        if isOpeningImmersiveSpace {
                            ProgressView()
                        } else {
                            Label("进入全景", systemImage: "visionpro")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!model.canEnterImmersiveSpace || isOpeningImmersiveSpace)
                }
                .controlSize(.large)
            }

            Text("进入后可直接转头环看；注视画面并捏合拖动可调整方向。")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(40)
        .fileImporter(
            isPresented: $showsFileImporter,
            allowedContentTypes: [.image],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case let .success(urls):
                guard let url = urls.first else { return }
                model.importPanorama(from: url)
            case let .failure(error):
                // Cancellation is represented as a file-importer error. Keeping
                // the previous panorama selected is the least surprising result.
                if (error as NSError).code != NSUserCancelledError {
                    model.reportFileImporterError(error)
                }
            }
        }
    }

    private func enterImmersiveSpace() {
        guard model.canEnterImmersiveSpace else { return }
        isOpeningImmersiveSpace = true

        Task {
            let result = await openImmersiveSpace(id: AppModel.immersiveSpaceID)
            switch result {
            case .opened:
                model.immersiveSpaceIsOpen = true
            case .userCancelled, .error:
                model.immersiveSpaceIsOpen = false
            @unknown default:
                model.immersiveSpaceIsOpen = false
            }
            isOpeningImmersiveSpace = false
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environmentObject(AppModel())
}
