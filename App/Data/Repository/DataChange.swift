import Foundation

extension Notification.Name {
    /// Phát sau mỗi lần ghi dữ liệu thành công.
    /// P4 (notification) và P7 (widget bridge) sẽ lắng nghe ở đây thay vì bị gọi trực tiếp.
    static let daylineDataChanged = Notification.Name("dayline.data.changed")
}
