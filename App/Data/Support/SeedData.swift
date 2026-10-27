import Foundation
import SwiftData

enum SeedData {
    /// Giờ tính tương đối so với hiện tại để màn Today luôn có task "đang làm".
    static func tasks(now: Date = .now) -> [TaskItem] {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: now)
        let minute = components.minute ?? 0
        components.minute = minute - (minute % 5)
        let rounded = calendar.date(from: components) ?? now

        func at(_ minutes: Int) -> Date {
            rounded.addingTimeInterval(TimeInterval(minutes * 60))
        }

        return [
            TaskItem(
                title: "Lập kế hoạch sprint 14",
                startAt: at(-200),
                durationMinutes: 30,
                isDone: true,
                completedAt: at(-195),
                sortIndex: 0
            ),
            TaskItem(
                title: "Đọc tài liệu SwiftUI 18",
                startAt: at(-150),
                durationMinutes: 30,
                isDone: true,
                completedAt: at(-140),
                sortIndex: 1
            ),
            TaskItem(
                title: "Họp review sprint",
                detail: "Phòng họp số 3, thảo luận kế hoạch phát hành v1.0",
                startAt: at(-20),
                durationMinutes: 60,
                priority: .high,
                reminderMinutesBefore: 5,
                sortIndex: 2
            ),
            TaskItem(
                title: "Viết API spec cho backend",
                startAt: at(60),
                durationMinutes: 60,
                reminderMinutesBefore: 10,
                sortIndex: 3
            ),
            TaskItem(
                title: "Kiểm tra pull request iOS",
                startAt: at(135),
                durationMinutes: 30,
                sortIndex: 4
            ),
            TaskItem(
                title: "Chạy bộ công viên 3km",
                startAt: at(180),
                durationMinutes: 30,
                recurrence: .daily,
                sortIndex: 5
            ),
            TaskItem(
                title: "Học tiếng Anh phản xạ",
                startAt: at(270),
                durationMinutes: 60,
                sortIndex: 6
            )
        ]
    }

    static func notes(now: Date = .now) -> [Note] {
        [
            Note(
                title: "Kế hoạch phát hành Dayline v1.0",
                body: "Tập trung hoàn thiện màn Hôm nay và widget Lock Screen. Kiểm tra bản tinted mode trước khi cài lên máy.",
                isPinned: true,
                tags: ["release"],
                updatedAt: now.addingTimeInterval(-3600)
            ),
            Note(
                title: "Ghi chú kiến trúc Widget & App Group",
                body: "App ghi snapshot JSON vào App Group, widget chỉ đọc snapshot. Không mở SwiftData trong widget extension.",
                isPinned: true,
                tags: ["widget", "architecture"],
                updatedAt: now.addingTimeInterval(-86_400)
            ),
            Note(
                title: "Danh sách phím tắt hữu ích",
                body: "Command + N để tạo nhanh ghi chú. Kéo thả để sắp xếp vị trí.",
                tags: ["tips"],
                updatedAt: now.addingTimeInterval(-3 * 86_400)
            ),
            Note(
                title: "Biên bản họp sprint 14",
                body: "Thống nhất giảm tải dung lượng IPA, ưu tiên thời gian khởi động dưới 0.4s.",
                tags: ["meeting"],
                updatedAt: now.addingTimeInterval(-4 * 86_400)
            ),
            Note(
                title: "Ý tưởng widget Lock Screen",
                body: "Một dòng giờ + tên việc tiếp theo, chữ to để liếc nhanh khi đang họp. Bản tinted chỉ dùng 1 màu accent.",
                tags: ["idea", "widget"],
                updatedAt: now.addingTimeInterval(-6 * 86_400)
            )
        ]
    }

    static func insertIfEmpty(into context: ModelContext, now: Date = .now) {
        let existing = (try? context.fetchCount(FetchDescriptor<TaskItem>())) ?? 0
        guard existing == 0 else { return }

        for task in tasks(now: now) {
            context.insert(task)
        }
        for note in notes(now: now) {
            context.insert(note)
        }
        try? context.save()
    }
}
