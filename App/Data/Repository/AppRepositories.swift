import Foundation
import SwiftData

/// Nơi duy nhất lấy repository cho UI.
/// Nếu SwiftData không mở được (App Group hỏng, ổ đầy…) thì dùng mock in-memory
/// để app vẫn chạy được thay vì màn hình trắng.
@MainActor
enum AppRepositories {
    static let tasks: TaskRepository = makeTaskRepository()
    static let notes: NoteRepository = makeNoteRepository()

    private static func makeTaskRepository() -> TaskRepository {
        guard let context = DataStore.shared.context else {
            return MockTaskRepository()
        }
        return SwiftDataTaskRepository(context: context)
    }

    private static func makeNoteRepository() -> NoteRepository {
        guard let context = DataStore.shared.context else {
            return MockNoteRepository()
        }
        return SwiftDataNoteRepository(context: context)
    }
}
