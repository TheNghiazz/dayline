import XCTest
@testable import Dayline

@MainActor
final class NoteRepositoryTests: XCTestCase {
    func testCreateAndSearchByTitleAndBody() throws {
        let stack = try TestStack.make()
        _ = try stack.notes.create(NoteDraft(title: "Kế hoạch release", body: "Widget lock screen"))
        _ = try stack.notes.create(NoteDraft(title: "Mua sữa", body: "Sữa hạt"))

        XCTAssertEqual(try stack.notes.notes(search: "release").count, 1)
        XCTAssertEqual(try stack.notes.notes(search: "widget").count, 1)
        XCTAssertEqual(try stack.notes.notes(search: "không có gì").count, 0)
        XCTAssertEqual(try stack.notes.notes(search: "  ").count, 2)
    }

    func testPinnedNotesComeFirst() throws {
        let stack = try TestStack.make()
        let pinned = try stack.notes.create(NoteDraft(title: "Ghim", body: ""))
        _ = try stack.notes.create(NoteDraft(title: "Thường", body: ""))

        try stack.notes.togglePin(pinned.id)

        XCTAssertEqual(try stack.notes.notes(search: "").first?.id, pinned.id)
    }

    func testUpdateChangesTitleAndTimestamp() throws {
        let stack = try TestStack.make()
        let note = try stack.notes.create(NoteDraft(title: "Cũ", body: "nội dung"))
        let before = note.updatedAt

        try stack.notes.update(note.id, with: NoteDraft(title: "Mới", body: "nội dung 2", tags: ["a"]))

        XCTAssertEqual(note.title, "Mới")
        XCTAssertEqual(note.body, "nội dung 2")
        XCTAssertEqual(note.tags, ["a"])
        XCTAssertGreaterThanOrEqual(note.updatedAt, before)
    }

    func testDeleteRemovesNote() throws {
        let stack = try TestStack.make()
        let note = try stack.notes.create(NoteDraft(title: "Xoá", body: ""))

        try stack.notes.delete(note.id)

        XCTAssertTrue(try stack.notes.notes(search: "").isEmpty)
    }

    func testPreviewTextFallsBackWhenBodyEmpty() throws {
        let stack = try TestStack.make()
        let note = try stack.notes.create(NoteDraft(title: "Trống", body: "   "))

        XCTAssertEqual(note.previewText, "Chưa có nội dung")
    }
}
