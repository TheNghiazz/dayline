import Foundation
import SwiftData
@testable import Dayline

@MainActor
enum TestStack {
    struct Stack {
        let container: ModelContainer
        let context: ModelContext
        let tasks: SwiftDataTaskRepository
        let notes: SwiftDataNoteRepository
    }

    static func make() throws -> Stack {
        let schema = Schema([TaskItem.self, Note.self])
        let container = try ModelContainer(
            for: schema,
            configurations: [ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)]
        )
        let context = container.mainContext
        return Stack(
            container: container,
            context: context,
            tasks: SwiftDataTaskRepository(context: context),
            notes: SwiftDataNoteRepository(context: context)
        )
    }

    /// Ngày cố định để test tất định (không phụ thuộc giờ chạy CI).
    static let baseDate = Date(timeIntervalSince1970: 1_700_000_000)

    static func at(hour: Int, minute: Int = 0, day: Date = baseDate) -> Date {
        Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: day)
            ?? day.addingTimeInterval(TimeInterval(hour * 3600 + minute * 60))
    }
}
