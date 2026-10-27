import Foundation

extension TaskItem {
    /// Giờ kết thúc dùng cho hiển thị/trạng thái: task có giờ nhưng không đặt
    /// `durationMinutes` được coi là kéo dài 30 phút.
    var scheduledEnd: Date? {
        guard let startAt else { return nil }
        let minutes = durationMinutes ?? Self.defaultDurationMinutes
        return startAt.addingTimeInterval(TimeInterval(minutes * 60))
    }

    /// "14:30 – 15:15" (hoặc "Cả ngày" nếu chưa xếp giờ).
    var displayTimeText: String {
        guard let start = startAt, let end = scheduledEnd else { return "Chưa xếp giờ" }
        return DLDateText.timeRange(from: start, to: end)
    }

    func rowState(at now: Date) -> TaskRowState {
        if isDone { return .done }
        guard let start = startAt, let end = scheduledEnd else { return .upcoming }
        if end <= now { return .overdue }
        if start <= now { return .current }
        return .upcoming
    }
}
