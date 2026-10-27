import XCTest
@testable import Dayline

@MainActor
final class TaskRepositoryTests: XCTestCase {
    func testCreateThenFetchForThatDay() throws {
        let stack = try TestStack.make()
        let task = try stack.tasks.create(
            TaskDraft(title: "Họp review", startAt: TestStack.at(hour: 9), durationMinutes: 30)
        )

        XCTAssertEqual(try stack.tasks.tasks(on: TestStack.baseDate).map(\.id), [task.id])
    }

    func testTaskOnAnotherDayIsExcluded() throws {
        let stack = try TestStack.make()
        let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: TestStack.baseDate)!

        _ = try stack.tasks.create(TaskDraft(title: "Mai", startAt: TestStack.at(hour: 9, day: nextDay)))

        XCTAssertTrue(try stack.tasks.tasks(on: TestStack.baseDate).isEmpty)
        XCTAssertEqual(try stack.tasks.tasks(on: nextDay).count, 1)
    }

    func testTaskWithoutTimeIsNotInAnyDay() throws {
        let stack = try TestStack.make()
        _ = try stack.tasks.create(TaskDraft(title: "Không giờ"))

        XCTAssertTrue(try stack.tasks.tasks(on: TestStack.baseDate).isEmpty)
    }

    func testToggleDoneSetsAndClearsCompletedAt() throws {
        let stack = try TestStack.make()
        let task = try stack.tasks.create(TaskDraft(title: "A", startAt: TestStack.at(hour: 9)))

        try stack.tasks.toggleDone(task.id)
        XCTAssertTrue(task.isDone)
        XCTAssertNotNil(task.completedAt)

        try stack.tasks.toggleDone(task.id)
        XCTAssertFalse(task.isDone)
        XCTAssertNil(task.completedAt)
    }

    func testDeleteRemovesTask() throws {
        let stack = try TestStack.make()
        let task = try stack.tasks.create(TaskDraft(title: "A", startAt: TestStack.at(hour: 9)))

        try stack.tasks.delete(task.id)

        XCTAssertTrue(try stack.tasks.tasks(on: TestStack.baseDate).isEmpty)
    }

    func testUpdateAppliesDraft() throws {
        let stack = try TestStack.make()
        let task = try stack.tasks.create(
            TaskDraft(title: "Cũ", startAt: TestStack.at(hour: 9), durationMinutes: 30)
        )

        var draft = TaskDraft(
            title: "Mới",
            startAt: TestStack.at(hour: 10),
            durationMinutes: 45,
            priority: .high
        )
        draft.detail = "chi tiết"
        draft.reminderMinutesBefore = 15
        draft.recurrence = .daily

        try stack.tasks.update(task.id, with: draft)

        XCTAssertEqual(task.title, "Mới")
        XCTAssertEqual(task.durationMinutes, 45)
        XCTAssertEqual(task.priority, .high)
        XCTAssertEqual(task.recurrence?.kind, .daily)
        XCTAssertEqual(task.detail, "chi tiết")
        XCTAssertEqual(task.reminderMinutesBefore, 15)
    }

    func testUpcomingSkipsDoneAndSorts() throws {
        let stack = try TestStack.make()
        let now = TestStack.at(hour: 12)

        let late = try stack.tasks.create(TaskDraft(title: "Muộn", startAt: TestStack.at(hour: 16)))
        let soon = try stack.tasks.create(TaskDraft(title: "Sớm", startAt: TestStack.at(hour: 13)))
        let done = try stack.tasks.create(TaskDraft(title: "Xong", startAt: TestStack.at(hour: 14)))
        _ = try stack.tasks.create(TaskDraft(title: "Quá khứ", startAt: TestStack.at(hour: 9)))

        try stack.tasks.toggleDone(done.id)

        let upcoming = try stack.tasks.upcoming(after: now, limit: 5)
        XCTAssertEqual(upcoming.map(\.id), [soon.id, late.id])
        XCTAssertEqual(try stack.tasks.nextTask(after: now)?.id, soon.id)
        XCTAssertEqual(try stack.tasks.upcoming(after: now, limit: 1).count, 1)
        XCTAssertTrue(try stack.tasks.upcoming(after: now, limit: 0).isEmpty)
    }

    func testRescheduleKeepsDuration() throws {
        let stack = try TestStack.make()
        let task = try stack.tasks.create(
            TaskDraft(title: "A", startAt: TestStack.at(hour: 9), durationMinutes: 30)
        )
        let newStart = TestStack.at(hour: 15)

        try stack.tasks.reschedule(task.id, to: newStart)

        XCTAssertEqual(task.startAt, newStart)
        XCTAssertEqual(task.durationMinutes, 30)
        XCTAssertEqual(task.endAt, newStart.addingTimeInterval(30 * 60))
    }

    func testWritesPostDataChangedNotification() throws {
        let stack = try TestStack.make()
        let expectation = expectation(forNotification: .daylineDataChanged, object: nil)

        _ = try stack.tasks.create(TaskDraft(title: "A", startAt: TestStack.at(hour: 9)))

        wait(for: [expectation], timeout: 1)
    }
}
