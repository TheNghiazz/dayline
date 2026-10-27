import Foundation
import OSLog
import WidgetKit

/// Ghi probe vào App Group và yêu cầu widget reload.
/// Trả `false` khi App Group không khả dụng (Apple ID free) — không throw ra UI.
enum ProbeRecorder {
    private static let logger = Logger(subsystem: "com.ngia.dayline", category: "probe")

    @discardableResult
    static func record(message: String = "ok") -> Bool {
        let snapshot = ProbeSnapshot(
            message: message,
            updatedAt: .now,
            appVersion: AppInfo.version,
            buildNumber: AppInfo.build
        )

        do {
            try ProbeStore.writeToSharedGroup(snapshot)
            logger.info("Probe written to \(AppGroup.identifier, privacy: .public)")
            WidgetCenter.shared.reloadAllTimelines()
            return true
        } catch {
            logger.error("Probe write failed: \(String(describing: error), privacy: .public)")
            return false
        }
    }
}
