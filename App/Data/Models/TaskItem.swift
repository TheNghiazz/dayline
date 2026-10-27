import Foundation
import SwiftData

@Model
final class TaskItem {
    @Attribute(.unique) var id: UUID
    var title: String
    var detail: String?
    var startAt: Date?
    var durationMinutes: Int?
    var isDone: Bool
    var completedAt: Date?
    var priorityRaw: Int
    var recurrenceRaw: String?
    var reminderMinutesBefore: Int?
    var createdAt: Date
    var sortIndex: Int

    init(
        id: UUID = UUID(),
        title: String,
        detail: String? = nil,
        startAt: Date? = nil,
        durationMinutes: Int? = nil,
        isDone: Bool = false,
        completedAt: Date? = nil,
        priority: Priority = .normal,
        recurrence: RecurrenceRule? = nil,
        reminderMinutesBefore: Int? = nil,
        createdAt: Date = .now,
        sortIndex: Int = 0
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.startAt = startAt
        self.durationMinutes = durationMinutes
        self.isDone = isDone
        self.completedAt = completedAt
        self.priorityRaw = priority.rawValue
        self.recurrenceRaw = recurrence?.encodedString
        self.reminderMinutesBefore = reminderMinutesBefore
        self.createdAt = createdAt
        self.sortIndex = sortIndex
    }

    var priority: Priority {
        get { Priority(rawValue: priorityRaw) ?? .normal }
        set { priorityRaw = newValue.rawValue }
    }

    var recurrence: RecurrenceRule? {
        get { RecurrenceRule(encoded: recurrenceRaw) }
        set { recurrenceRaw = newValue?.encodedString }
    }

    var endAt: Date? {
        guard let startAt, let durationMinutes else { return nil }
        return startAt.addingTimeInterval(TimeInterval(durationMinutes * 60))
    }
}

extension Array where Element == TaskItem {
    /// Task có giờ đứng trước, cùng giờ thì theo `sortIndex`; task không giờ xuống cuối.
    func sortedByStart() -> [TaskItem] {
        sorted { lhs, rhs in
            switch (lhs.startAt, rhs.startAt) {
            case let (l?, r?):
                if l == r { return lhs.sortIndex < rhs.sortIndex }
                return l < r
            case (nil, .some):
                return false
            case (.some, nil):
                return true
            case (nil, nil):
                return lhs.sortIndex < rhs.sortIndex
            }
        }
    }
}
