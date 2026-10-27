import XCTest
@testable import Dayline

final class DayAggregateTests: XCTestCase {
    private let calendar = Calendar.current

    private var baseDay: Date {
        calendar.startOfDay(for: Date(timeIntervalSince1970: 1_700_000_000))
    }

    private func at(_ hour: Int, _ minute: Int = 0, day: Date? = nil) -> Date {
        calendar.date(bySettingHour: hour, minute: minute, second: 0, of: day ?? baseDay)
            ?? baseDay.addingTimeInterval(TimeInterval(hour * 3600 + minute * 60))
    }

    private func make(_ title: String, _ start: Date, _ minutes: Int? = 30, done: Bool = false) -> TaskItem {
        TaskItem(
            title: title,
            startAt: start,
            durationMinutes: minutes,
            isDone: done
        )
    }

    func testSplitsIntoSections() {
        let overdue = make("Quá hạn", at(9))
        let running = make("Đang làm", at(10), 60)
        let upcoming = make("Sắp tới", at(12))
        let finished = make("Đã xong", at(8), 30, done: true)

        let aggregate = DayAggregate.make(
            tasks: [upcoming, finished, overdue, running],
            on: baseDay,
            now: at(10, 30),
            calendar: calendar
        )

        XCTAssertEqual(aggregate.running.map(\.title), ["Đang làm"])
        XCTAssertEqual(aggregate.overdue.map(\.title), ["Quá hạn"])
        XCTAssertEqual(aggregate.upcoming.map(\.title), ["Sắp tới"])
        XCTAssertEqual(aggregate.done.map(\.title), ["Đã xong"])
        XCTAssertEqual(aggregate.total, 4)
        XCTAssertEqual(aggregate.doneCount, 1)
        XCTAssertFalse(aggregate.isEmpty)
    }

    func testMultipleRunningTasksKeepTimeOrder() {
        let first = make("A", at(10), 90)
        let second = make("B", at(10, 15), 90)

        let aggregate = DayAggregate.make(
            tasks: [second, first],
            on: baseDay,
            now: at(10, 30),
            calendar: calendar
        )

        XCTAssertEqual(aggregate.running.map(\.title), ["A", "B"])
        XCTAssertTrue(aggregate.upcoming.isEmpty)
    }

    func testTaskWithoutDurationUsesDefaultLength() {
        let task = make("Không thời lượng", at(10), nil)

        let during = DayAggregate.make(tasks: [task], on: baseDay, now: at(10, 29), calendar: calendar)
        XCTAssertEqual(during.running.count, 1)

        let after = DayAggregate.make(tasks: [task], on: baseDay, now: at(10, 30), calendar: calendar)
        XCTAssertEqual(after.overdue.count, 1)
        XCTAssertTrue(after.running.isEmpty)
    }

    func testTaskIsOverdueExactlyAtItsEnd() {
        let task = make("Kết thúc 10:30", at(10), 30)

        let aggregate = DayAggregate.make(
            tasks: [task],
            on: baseDay,
            now: at(10, 30),
            calendar: calendar
        )

        XCTAssertEqual(aggregate.overdue.count, 1)
        XCTAssertEqual(task.rowState(at: at(10, 30)), .overdue)
    }

    func testTaskOnAnotherDayIsIgnored() {
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: baseDay) ?? baseDay
        let task = make("Mai", at(9, 0, day: tomorrow))

        let aggregate = DayAggregate.make(tasks: [task], on: baseDay, now: at(9), calendar: calendar)

        XCTAssertTrue(aggregate.isEmpty)
    }

    func testTaskWithoutStartIsIgnored() {
        let task = TaskItem(title: "Chưa xếp giờ")

        let aggregate = DayAggregate.make(tasks: [task], on: baseDay, now: at(9), calendar: calendar)

        XCTAssertTrue(aggregate.isEmpty)
    }

    func testDoneTaskIgnoresClock() {
        let task = make("Xong sớm", at(18), 30, done: true)

        let aggregate = DayAggregate.make(tasks: [task], on: baseDay, now: at(9), calendar: calendar)

        XCTAssertEqual(aggregate.done.count, 1)
        XCTAssertEqual(aggregate.running.count, 0)
        XCTAssertEqual(aggregate.upcoming.count, 0)
        XCTAssertEqual(aggregate.overdue.count, 0)
    }

    func testRowStateMatchesSections() {
        let now = at(10, 30)
        XCTAssertEqual(make("A", at(9), 30).rowState(at: now), .overdue)
        XCTAssertEqual(make("B", at(10), 60).rowState(at: now), .current)
        XCTAssertEqual(make("C", at(12)).rowState(at: now), .upcoming)
        XCTAssertEqual(make("D", at(10), 60, done: true).rowState(at: now), .done)
    }

    func testDisplayTimeTextFallsBackWhenNoStart() {
        XCTAssertEqual(TaskItem(title: "A").displayTimeText, "Chưa xếp giờ")
        XCTAssertFalse(make("B", at(14, 5), 45).displayTimeText.isEmpty)
    }
}
