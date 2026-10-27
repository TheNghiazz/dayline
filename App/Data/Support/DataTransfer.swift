import Foundation
import SwiftData

struct ExportPayload: Codable, Equatable {
    struct TaskRecord: Codable, Equatable {
        var id: UUID
        var title: String
        var detail: String?
        var startAt: Date?
        var durationMinutes: Int?
        var isDone: Bool
        var completedAt: Date?
        var priority: Int
        var recurrence: RecurrenceRule?
        var reminderMinutesBefore: Int?
        var createdAt: Date
    }

    struct NoteRecord: Codable, Equatable {
        var id: UUID
        var title: String
        var body: String
        var isPinned: Bool
        var tags: [String]
        var createdAt: Date
        var updatedAt: Date
    }

    var schemaVersion: Int
    var exportedAt: Date
    var tasks: [TaskRecord]
    var notes: [NoteRecord]
}

enum DataTransferError: Error, Equatable {
    case unsupportedSchema(Int)
}

enum DataTransfer {
    static let currentSchemaVersion = 1

    // MARK: - Export

    static func export(tasks: [TaskItem], notes: [Note], now: Date = .now) throws -> Data {
        let payload = ExportPayload(
            schemaVersion: currentSchemaVersion,
            exportedAt: now,
            tasks: tasks.map { task in
                ExportPayload.TaskRecord(
                    id: task.id,
                    title: task.title,
                    detail: task.detail,
                    startAt: task.startAt,
                    durationMinutes: task.durationMinutes,
                    isDone: task.isDone,
                    completedAt: task.completedAt,
                    priority: task.priorityRaw,
                    recurrence: task.recurrence,
                    reminderMinutesBefore: task.reminderMinutesBefore,
                    createdAt: task.createdAt
                )
            },
            notes: notes.map { note in
                ExportPayload.NoteRecord(
                    id: note.id,
                    title: note.title,
                    body: note.body,
                    isPinned: note.isPinned,
                    tags: note.tags,
                    createdAt: note.createdAt,
                    updatedAt: note.updatedAt
                )
            }
        )
        return try DaylineCoding.encoder.encode(payload)
    }

    static func exportAll(in context: ModelContext, now: Date = .now) throws -> Data {
        let tasks = try context.fetch(FetchDescriptor<TaskItem>()).sortedByStart()
        let notes = try context.fetch(FetchDescriptor<Note>())
        return try export(tasks: tasks, notes: notes, now: now)
    }

    // MARK: - Import

    static func decode(_ data: Data) throws -> ExportPayload {
        let payload = try DaylineCoding.decoder.decode(ExportPayload.self, from: data)
        guard payload.schemaVersion == currentSchemaVersion else {
            throw DataTransferError.unsupportedSchema(payload.schemaVersion)
        }
        return payload
    }

    /// Bỏ qua bản ghi trùng `id` để import nhiều lần không nhân đôi dữ liệu.
    @discardableResult
    static func importAll(from data: Data, into context: ModelContext) throws -> (tasks: Int, notes: Int) {
        let payload = try decode(data)

        let existingTaskIDs = Set(try context.fetch(FetchDescriptor<TaskItem>()).map(\.id))
        let existingNoteIDs = Set(try context.fetch(FetchDescriptor<Note>()).map(\.id))

        var insertedTasks = 0
        for record in payload.tasks where !existingTaskIDs.contains(record.id) {
            context.insert(
                TaskItem(
                    id: record.id,
                    title: record.title,
                    detail: record.detail,
                    startAt: record.startAt,
                    durationMinutes: record.durationMinutes,
                    isDone: record.isDone,
                    completedAt: record.completedAt,
                    priority: Priority(rawValue: record.priority) ?? .normal,
                    recurrence: record.recurrence,
                    reminderMinutesBefore: record.reminderMinutesBefore,
                    createdAt: record.createdAt
                )
            )
            insertedTasks += 1
        }

        var insertedNotes = 0
        for record in payload.notes where !existingNoteIDs.contains(record.id) {
            context.insert(
                Note(
                    id: record.id,
                    title: record.title,
                    body: record.body,
                    isPinned: record.isPinned,
                    tags: record.tags,
                    createdAt: record.createdAt,
                    updatedAt: record.updatedAt
                )
            )
            insertedNotes += 1
        }

        if context.hasChanges {
            try context.save()
        }
        return (insertedTasks, insertedNotes)
    }
}
