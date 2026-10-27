import Foundation
import SwiftData

/// Repository giả cho preview/UI test: cùng protocol, không cần SwiftData.
@MainActor
final class MockTaskRepository: TaskRepository {
    private var items: [TaskItem]
    private let calendar: Calendar

    init(items: [TaskItem] = SeedData.tasks(), calendar: Calendar = .current) {
        self.items = items
        self.calendar = calendar
    }

    func tasks(on day: Date) throws -> [TaskItem] {
        items
            .filter { task in
                guard let start = task.startAt else { return false }
                return calendar.isDate(start, inSameDayAs: day)
            }
            .sortedByStart()
    }

    func upcoming(after date: Date, limit: Int) throws -> [TaskItem] {
        items
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
            reminderMinutesBefore: draft.reminderMinutesBefore,
            sortIndex: items.count
        )
        items.append(task)
        return task
    }

    func update(_ id: UUID, with draft: TaskDraft) throws {
        guard let task = items.first(where: { $0.id == id }) else { return }
        task.title = draft.title
        task.detail = draft.detail
        task.startAt = draft.startAt
        task.durationMinutes = draft.durationMinutes
        task.priority = draft.priority
        task.recurrence = draft.recurrence
        task.reminderMinutesBefore = draft.reminderMinutesBefore
    }

    func toggleDone(_ id: UUID) throws {
        guard let task = items.first(where: { $0.id == id }) else { return }
        task.isDone.toggle()
        task.completedAt = task.isDone ? .now : nil
    }

    func delete(_ id: UUID) throws {
        items.removeAll { $0.id == id }
    }

    func reschedule(_ id: UUID, to start: Date) throws {
        guard let task = items.first(where: { $0.id == id }) else { return }
        task.startAt = start
    }
}

@MainActor
final class MockNoteRepository: NoteRepository {
    private var items: [Note]

    init(items: [Note] = SeedData.notes()) {
        self.items = items
    }

    func notes(search: String) throws -> [Note] {
        let query = search.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return items
            .filter { note in
                guard !query.isEmpty else { return true }
                return note.title.lowercased().contains(query) || note.body.lowercased().contains(query)
            }
            .sorted { lhs, rhs in
                if lhs.isPinned != rhs.isPinned { return lhs.isPinned }
                return lhs.updatedAt > rhs.updatedAt
            }
    }

    @discardableResult
    func create(_ draft: NoteDraft) throws -> Note {
        let note = Note(title: draft.title, body: draft.body, tags: draft.tags)
        items.append(note)
        return note
    }

    func update(_ id: UUID, with draft: NoteDraft) throws {
        guard let note = items.first(where: { $0.id == id }) else { return }
        note.title = draft.title
        note.body = draft.body
        note.tags = draft.tags
        note.updatedAt = .now
    }

    func delete(_ id: UUID) throws {
        items.removeAll { $0.id == id }
    }

    func togglePin(_ id: UUID) throws {
        guard let note = items.first(where: { $0.id == id }) else { return }
        note.isPinned.toggle()
        note.updatedAt = .now
    }
}
