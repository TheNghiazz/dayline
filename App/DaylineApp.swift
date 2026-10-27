import SwiftUI

@main
struct DaylineApp: App {
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .task {
                    await bootstrap()
                    ProbeRecorder.record()
                }
                .onChange(of: scenePhase) { _, phase in
                    guard phase == .active else { return }
                    ProbeRecorder.record()
                }
        }
    }

    /// Chỉ chạy khi có cờ `-uiTestSeed` / `-uiTestReset` (CI và lúc cần demo).
    @MainActor
    private func bootstrap() {
        let options = LaunchOptions.current
        guard options.seedData || options.resetData else { return }
        guard let context = DataStore.shared.context else { return }

        if options.resetData {
            try? context.delete(model: TaskItem.self)
            try? context.delete(model: Note.self)
            try? context.save()
        }

        if options.seedData {
            SeedData.insertIfEmpty(into: context)
        }
    }
}
