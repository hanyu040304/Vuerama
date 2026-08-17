import RealityKit
import SwiftUI

struct ImmersiveView: View {
    private static let sphereName = "VueramaPanoramaSphere"

    @EnvironmentObject private var model: AppModel
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    @State private var dragStart: ViewingOffset?
    @State private var loadState: LoadState = .loading

    var body: some View {
        ZStack(alignment: .bottom) {
            RealityView { content in
                guard let imageURL = model.panorama?.localURL else {
                    loadState = .failed("没有可显示的全景照片。")
                    return
                }

                do {
                    let texture = try await TextureResource(
                        contentsOf: imageURL,
                        withName: imageURL.lastPathComponent
                    )
                    var material = UnlitMaterial()
                    material.color = .init(texture: .init(texture))

                    let sphere = ModelEntity(
                        mesh: .generateSphere(radius: 10),
                        materials: [material]
                    )
                    sphere.name = Self.sphereName

                    // Reverse triangle winding so the generated sphere is visible
                    // from its center. This also keeps the image unlit and neutral.
                    sphere.scale = SIMD3<Float>(-1, 1, 1)
                    sphere.components.set(InputTargetComponent())
                    sphere.components.set(
                        CollisionComponent(
                            shapes: [.generateSphere(radius: 10)]
                        )
                    )

                    // An immersive space starts near the user's feet. Anchor the
                    // sphere to the head for one frame only so its center is at
                    // eye level, then leave it fixed for natural look-around.
                    let headAnchor = AnchorEntity(.head)
                    headAnchor.anchoring.trackingMode = .once
                    headAnchor.addChild(sphere)
                    content.add(headAnchor)
                    loadState = .ready
                } catch {
                    loadState = .failed("纹理载入失败：\(error.localizedDescription)")
                }
            } update: { content in
                guard let sphere = content.entities.lazy.compactMap({
                    $0.findEntity(named: Self.sphereName)
                }).first else {
                    return
                }

                let yawRotation = simd_quatf(
                    angle: model.viewingOffset.yaw,
                    axis: SIMD3<Float>(0, 1, 0)
                )
                let pitchRotation = simd_quatf(
                    angle: model.viewingOffset.pitch,
                    axis: SIMD3<Float>(1, 0, 0)
                )
                sphere.transform.rotation = yawRotation * pitchRotation
            }
            .gesture(panoramaDragGesture)

            switch loadState {
            case .loading:
                statusPanel {
                    ProgressView("正在载入全景照片…")
                }
            case let .failed(message):
                statusPanel {
                    Label(message, systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                }
            case .ready:
                EmptyView()
            }

            HStack(spacing: 14) {
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
            .padding(18)
            .glassBackgroundEffect()
            .padding(.bottom, 42)
        }
        .onDisappear {
            model.didCloseImmersiveSpace()
        }
    }

    private var panoramaDragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .targetedToAnyEntity()
            .onChanged { value in
                if dragStart == nil {
                    dragStart = model.viewingOffset
                }

                guard var offset = dragStart else { return }
                offset.applyDrag(
                    horizontal: Float(value.gestureValue.translation.width),
                    vertical: Float(value.gestureValue.translation.height)
                )
                model.viewingOffset = offset
            }
            .onEnded { _ in
                dragStart = nil
            }
    }

    @ViewBuilder
    private func statusPanel<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {
        content()
            .padding(18)
            .glassBackgroundEffect()
            .padding(.bottom, 130)
    }
}

private enum LoadState {
    case loading
    case ready
    case failed(String)
}
