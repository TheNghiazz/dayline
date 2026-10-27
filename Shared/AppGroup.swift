import Foundation

/// Nơi duy nhất trong app đụng tới App Group.
/// Nếu entitlement không được cấp (Apple ID free), `containerURL` trả `nil`
/// và mọi thứ liên quan tới widget sẽ dùng trạng thái fallback thay vì crash.
enum AppGroup {
    static let identifier = "group.com.ngia.dayline"

    static var containerURL: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: identifier)
    }

    static var isAvailable: Bool {
        containerURL != nil
    }

    static var statusText: String {
        isAvailable ? "Đã kết nối" : "Không khả dụng"
    }
}
