import XCTest
@testable import Dayline

final class DataTransferTests: XCTestCase {
    @MainActor
    func testExportThenDecodeKeepsIdentity() throws {
        let stack = try TestStack.make()
        let task = try stack.tasks.create(
            TaskDraft(title: "Họp", startAt: TestStack.at(hour: 9), durationMinutes: 30)
        )
        let note = try stack.notes.create(NoteDraft(title: "Ghi chú", body: "Nội dung", tags: ["x"]))

        let data = try DataTransfer.exportAll(in: stack.context, now: TestStack.baseDate)
        let payload = try DataTransfer.decode(data)

        XCTAssertEqual(payload.schemaVersion, DataTransfer.currentSchemaVersion)
        XCTAssertEqual(payload.exportedAt, TestStack.baseDate)
        XCTAssertEqual(payload.tasks.map(\.id), [task.id])
        XCTAssertEqual(payload.notes.map(\.id), [note.id])
        XCTAssertEqual(payload.tasks.first?.title, "Họp")
        XCTAssertEqual(payload.notes.first?.tags, ["x"])
    }

    @MainActor
    func testImportIntoEmptyStoreAndSkipsDuplicates() throws {
        let source = try TestStack.make()
        _ = try source.tasks.create(TaskDraft(title: "A", startAt: TestStack.at(hour: 9)))
        _ = try source.notes.create(NoteDraft(title: "N", body: "B"))
        let data = try DataTransfer.exportAll(in: source.context, now: TestStack.baseDate)

        let target = try TestStack.make()
        let first = try DataTransfer.importAll(from: data, into: target.context)
        XCTAssertEqual(first.tasks, 1)
        XCTAssertEqual(first.notes, 1)

        let second = try DataTransfer.importAll(from: data, into: target.context)
        XCTAssertEqual(second.tasks, 0)
        XCTAssertEqual(second.notes, 0)

        XCTAssertEqual(try target.tasks.tasks(on: TestStack.baseDate).count, 1)
        XCTAssertEqual(try target.notes.notes(search: "").count, 1)
    }

    @MainActor
    func testUnsupportedSchemaThrows() throws {
        let payload = ExportPayload(
            schemaVersion: 99,
            exportedAt: TestStack.baseDate,
            tasks: [],
            notes: []
        )
        let data = try DaylineCoding.encoder.encode(payload)

        XCTAssertThrowsError(try DataTransfer.decode(data)) { error in
            XCTAssertEqual(error as? DataTransferError, .unsupportedSchema(99))
        }
    }

    func testRecurrenceRuleRoundTrip() {
        let rule = RecurrenceRule(kind: .weekdays, weekdays: [2, 4, 6], interval: 1)

        XCTAssertEqual(RecurrenceRule(encoded: rule.encodedString), rule)
        XCTAssertNil(RecurrenceRule(encoded: "không phải json"))
        XCTAssertNil(RecurrenceRule(encoded: nil))
    }

    func testRecurrenceIntervalIsClamped() {
        XCTAssertEqual(RecurrenceRule(kind: .everyNDays, interval: 0).interval, 1)
        XCTAssertEqual(RecurrenceRule(kind: .everyNDays, interval: 3).interval, 3)
    }
}
