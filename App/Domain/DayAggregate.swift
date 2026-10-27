import Foundation

/// Gom việc của một ngày thành các nhóm hiển thị trên Today.
/// Không phụ thuộc SwiftData nên test được bằng object thuần.
struct DayAggregate {
    var running: [TaskItem] = []
    var overdue: [TaskItem] = []
    var upcoming: [TaskItem] = []
    var done: [TaskItem] = []

    var total: Int { running.count + overdue.count + upcoming.count + done.count }
    var doneCount: Int { done.count }
    var isEmpty: Bool { total == 0 }

    /// - running: đang trong khoảng start...end
    /// - overdue: đã qua end mà chưa tick done
    /// - upcoming: start ở tương lai
    /// - done: đã tick (giữ nguyên thứ tự giờ)
    ///
    /// Task không có `startAt` bị bỏ qua — Today là timeline theo giờ.
    static func make(
        tasks: [TaskItem],
        on day: Date,
        now: Date,
        calendar: Calendar = .current
    ) -> DayAggregate {
        let dayTasks = tasks
            .filter { task in
                guard let start = task.startAt else { return false }
                return calendar.isDate(start, inSameDayAs: day)
            }
            .sortedByStart()

        var aggregate = DayAggregate()
        for task in dayTasks {
            if task.isDone {
                aggregate.done.append(task)
                continue
            }
            guard let start = task.startAt, let end = task.scheduledEnd else { continue }

            if end <= now {
                aggregate.overdue.append(task)
            } else if start <= now {
                aggregate.running.append(task)
            } else {
                aggregate.upcoming.append(task)
            }
        }
        return aggregate
    }
}
