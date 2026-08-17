import SwiftUI

@main
struct VueramaApp: App {
    @StateObject private var model = AppModel()
    @State private var immersionStyle: ImmersionStyle = .full

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(model)
        }
        .defaultSize(width: 620, height: 500)

        ImmersiveSpace(id: AppModel.immersiveSpaceID) {
            ImmersiveView()
                .environmentObject(model)
        }
        .immersionStyle(selection: $immersionStyle, in: .full)
    }
}
