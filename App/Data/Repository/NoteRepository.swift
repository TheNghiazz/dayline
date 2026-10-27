import Foundation
import SwiftData

@MainActor
protocol NoteRepository: AnyObject {
    func notes(search: String) throws -> [Note]
    @discardableResult func create(_ draft: NoteDraft) throws -> Note
    func update(_ id: UUID, with draft: NoteDraft) throws
    func delete(_ id: UUID) throws
    func togglePin(_ id: UUID) throws
}

@MainActor
final class SwiftDataNoteRepository: NoteRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func notes(search: String) throws -> [Note] {
        let query = search.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        return try all()
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
        let note = Note(
            title: draft.title.trimmingCharacters(in: .whitespacesAndNewlines),
            body: draft.body,
            tags: draft.tags
        )
        context.insert(note)
        try save()
        return note
    }

    func update(_ id: UUID, with draft: NoteDraft) throws {
        guard let note = try find(id) else { return }
        note.title = draft.title.trimmingCharacters(in: .whitespacesAndNewlines)
        note.body = draft.body
        note.tags = draft.tags
        note.updatedAt = .now
        try save()
    }

    func delete(_ id: UUID) throws {
        guard let note = try find(id) else { return }
        context.delete(note)
        try save()
    }

    func togglePin(_ id: UUID) throws {
        guard let note = try find(id) else { return }
        note.isPinned.toggle()
        note.updatedAt = .now
        try save()
    }

    // MARK: - Private

    private func all() throws -> [Note] {
        try context.fetch(FetchDescriptor<Note>())
    }

    private func find(_ id: UUID) throws -> Note? {
        try all().first { $0.id == id }
    }

    private func save() throws {
        guard context.hasChanges else { return }
        try context.save()
        NotificationCenter.default.post(name: .daylineDataChanged, object: nil)
    }
}
