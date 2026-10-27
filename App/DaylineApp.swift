import SwiftUI

@main
struct DaylineApp: App {
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .task {
                    ProbeRecorder.record()
                }
                .onChange(of: scenePhase) { _, phase in
                    guard phase == .active else { return }
                    ProbeRecorder.record()
                }
        }
    }
}
