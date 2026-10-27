import Foundation
import SwiftData

/// Nơi duy nhất tạo `ModelContainer`.
/// Thứ tự thử: App Group → thư mục mặc định → in-memory (chỉ để app không crash).
@MainActor
final class DataStore {
    enum State {
        case ready(ModelContainer)
        case failed(String)
    }

    static let shared = DataStore()
    static let schema = Schema([TaskItem.self, Note.self])

    let state: State
    /// "app-group" | "local" | "memory" | "unknown"
    let storageLabel: String

    private init() {
        var attempts: [(name: String, configuration: ModelConfiguration)] = []

        if let directory = AppGroup.containerURL {
            attempts.append((
                "app-group",
                ModelConfiguration(
                    schema: Self.schema,
                    url: directory.appendingPathComponent("Dayline.store")
                )
            ))
        }

        attempts.append(("local", ModelConfiguration(schema: Self.schema)))
        attempts.append(("memory", ModelConfiguration(schema: Self.schema, isStoredInMemoryOnly: true)))

        var container: ModelContainer?
        var label = "unknown"
        var errors: [String] = []

        for attempt in attempts {
            do {
                container = try ModelContainer(for: Self.schema, configurations: [attempt.configuration])
                label = attempt.name
                break
            } catch {
                errors.append("\(attempt.name): \(error.localizedDescription)")
            }
        }

        storageLabel = label
        if let container {
            state = .ready(container)
        } else {
            state = .failed(errors.joined(separator: "\n"))
        }
    }

    var context: ModelContext? {
        guard case let .ready(container) = state else { return nil }
        return container.mainContext
    }

    var isReady: Bool {
        context != nil
    }

    var failureMessage: String? {
        guard case let .failed(message) = state else { return nil }
        return message
    }

    var counts: (tasks: Int, notes: Int) {
        guard let context else { return (0, 0) }
        let tasks = (try? context.fetchCount(FetchDescriptor<TaskItem>())) ?? 0
        let notes = (try? context.fetchCount(FetchDescriptor<Note>())) ?? 0
        return (tasks, notes)
    }
}
