import Foundation
import SwiftData

@MainActor
protocol TaskRepository: AnyObject {
    func tasks(on day: Date) throws -> [TaskItem]
    func upcoming(after date: Date, limit: Int) throws -> [TaskItem]
    func nextTask(after date: Date) throws -> TaskItem?
    @discardableResult func create(_ draft: TaskDraft) throws -> TaskItem
    func update(_ id: UUID, with draft: TaskDraft) throws
    func toggleDone(_ id: UUID) throws
    func delete(_ id: UUID) throws
    func reschedule(_ id: UUID, to start: Date) throws
}

@MainActor
final class SwiftDataTaskRepository: TaskRepository {
    private let context: ModelContext
    private let calendar: Calendar

    init(context: ModelContext, calendar: Calendar = .current) {
        self.context = context
        self.calendar = calendar
    }

    func tasks(on day: Date) throws -> [TaskItem] {
        try all()
            .filter { task in
                guard let start = task.startAt else { return false }
                return calendar.isDate(start, inSameDayAs: day)
            }
            .sortedByStart()
    }

    func upcoming(after date: Date, limit: Int) throws -> [TaskItem] {
        try all()
            .filter { task in
                guard !task.isDone, let start = task.startAt else { return false }
                return start >= date
            }
            .sortedByStart()
            .prefix(max(0, limit))
            .map { $0 }
    }

    func nextTask(after date: Date) throws -> TaskItem? {
        try upcoming(after: date, limit: 1).first
    }

    @discardableResult
    func create(_ draft: TaskDraft) throws -> TaskItem {
        let task = TaskItem(
            title: draft.title,
            detail: draft.detail,
            startAt: draft.startAt,
            durationMinutes: draft.durationMinutes,
            priority: draft.priority,
            recurrence: draft.recurrence,
            reminderMinutesBefore: draft.reminderMinutesBefore
        )
        context.insert(task)
        try save()
        return task
    }

    func update(_ id: UUID, with draft: TaskDraft) throws {
        guard let task = try find(id) else { return }
        task.title = draft.title
        task.detail = draft.detail
        task.startAt = draft.startAt
        task.durationMinutes = draft.durationMinutes
        task.priority = draft.priority
        task.recurrence = draft.recurrence
        task.reminderMinutesBefore = draft.reminderMinutesBefore
        try save()
    }

    func toggleDone(_ id: UUID) throws {
        guard let task = try find(id) else { return }
        task.isDone.toggle()
        task.completedAt = task.isDone ? .now : nil
        try save()
    }

    func delete(_ id: UUID) throws {
        guard let task = try find(id) else { return }
        context.delete(task)
        try save()
    }

    func reschedule(_ id: UUID, to start: Date) throws {
        guard let task = try find(id) else { return }
        task.startAt = start
        try save()
    }

    // MARK: - Private

    private func all() throws -> [TaskItem] {
        try context.fetch(FetchDescriptor<TaskItem>())
    }

    private func find(_ id: UUID) throws -> TaskItem? {
        try all().first { $0.id == id }
    }

    private func save() throws {
        guard context.hasChanges else { return }
        try context.save()
        NotificationCenter.default.post(name: .daylineDataChanged, object: nil)
    }
}
