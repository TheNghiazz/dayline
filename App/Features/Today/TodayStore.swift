import Foundation
import Observation

/// Trạng thái của màn Hôm nay. Giữ `now` riêng để có thể tick mỗi 30 giây
/// và tự chuyển sang ngày mới khi qua nửa đêm.
@MainActor
@Observable
final class TodayStore {
    private let repository: TaskRepository

    private(set) var day: Date
    private(set) var now: Date
    private(set) var tasks: [TaskItem] = []
    private(set) var errorMessage: String?

    init(repository: TaskRepository, day: Date = .now, now: Date = .now) {
        self.repository = repository
        self.day = day
        self.now = now
    }

    var aggregate: DayAggregate {
        DayAggregate.make(tasks: tasks, on: day, now: now)
    }

    func load() {
        do {
            tasks = try repository.tasks(on: day)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func tick() {
        now = .now
        guard !Calendar.current.isDate(day, inSameDayAs: now) else { return }
        day = now
        load()
    }

    /// Vòng cập nhật cho màn Today: nạp dữ liệu rồi tick mỗi 30 giây.
    func runClock() async {
        load()
        while !Task.isCancelled {
            tick()
            try? await Task.sleep(for: .seconds(30))
        }
    }

    func toggle(_ task: TaskItem) {
        perform { try repository.toggleDone(task.id) }
    }

    func delete(_ task: TaskItem) {
        perform { try repository.delete(task.id) }
    }

    func save(_ draft: TaskDraft, editing task: TaskItem?) {
        var draft = draft
        draft.title = draft.title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !draft.title.isEmpty else { return }

        perform {
            if let task {
                try repository.update(task.id, with: draft)
            } else {
                try repository.create(draft)
            }
        }
    }

    private func perform(_ action: () throws -> Void) {
        do {
            try action()
            load()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
