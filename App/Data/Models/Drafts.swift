import Foundation

struct TaskDraft: Equatable {
    var title: String = ""
    var detail: String?
    var startAt: Date?
    var durationMinutes: Int?
    var priority: Priority = .normal
    var recurrence: RecurrenceRule?
    var reminderMinutesBefore: Int?

    init(
        title: String = "",
        detail: String? = nil,
        startAt: Date? = nil,
        durationMinutes: Int? = nil,
        priority: Priority = .normal,
        recurrence: RecurrenceRule? = nil,
        reminderMinutesBefore: Int? = nil
    ) {
        self.title = title
        self.detail = detail
        self.startAt = startAt
        self.durationMinutes = durationMinutes
        self.priority = priority
        self.recurrence = recurrence
        self.reminderMinutesBefore = reminderMinutesBefore
    }
}

struct NoteDraft: Equatable {
    var title: String = ""
    var body: String = ""
    var tags: [String] = []

    init(title: String = "", body: String = "", tags: [String] = []) {
        self.title = title
        self.body = body
        self.tags = tags
    }
}
