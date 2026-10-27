import Foundation

enum AppInfo {
    static var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "—"
    }

    static var build: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "—"
    }

    static var bundleIdentifier: String {
        Bundle.main.bundleIdentifier ?? "—"
    }

    static var displayVersion: String {
        "v\(version) (\(build))"
    }

    static let widgetBundleIdentifier = "com.ngia.dayline.widgets"
    static let appGroupIdentifier = AppGroup.identifier
}
