import Foundation

struct TodayTask: Identifiable, Equatable {
    let id: UUID
    var title: String
    var start: Date
    var end: Date
    var isDone: Bool

    init(id: UUID = UUID(), title: String, start: Date, end: Date, isDone: Bool = false) {
        self.id = id
        self.title = title
        self.start = start
        self.end = end
        self.isDone = isDone
    }

    func state(at now: Date) -> TaskRowState {
        if isDone { return .done }
        if now >= start, now < end { return .current }
        if end <= now { return .overdue }
        return .upcoming
    }

    var timeText: String {
        DLDateText.timeRange(from: start, to: end)
    }
}

extension TodayTask {
    /// Dữ liệu mẫu cho P1. P2 sẽ thay bằng SwiftData + repository.
    /// Giờ được tính tương đối so với hiện tại để màn luôn có task "đang làm".
    static func sample(now: Date = .now) -> [TodayTask] {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: now)
        let minute = components.minute ?? 0
        components.minute = minute - (minute % 5)
        let rounded = calendar.date(from: components) ?? now

        func at(_ minutes: Int) -> Date {
            rounded.addingTimeInterval(TimeInterval(minutes * 60))
        }

        return [
            .init(title: "Lập kế hoạch sprint 14", start: at(-200), end: at(-170), isDone: true),
            .init(title: "Đọc tài liệu SwiftUI 18", start: at(-150), end: at(-120), isDone: true),
            .init(title: "Họp review sprint", start: at(-20), end: at(40)),
            .init(title: "Viết API spec cho backend", start: at(60), end: at(120)),
            .init(title: "Kiểm tra pull request iOS", start: at(135), end: at(165)),
            .init(title: "Chạy bộ công viên 3km", start: at(180), end: at(210)),
            .init(title: "Học tiếng Anh phản xạ", start: at(270), end: at(330))
        ]
    }
}
