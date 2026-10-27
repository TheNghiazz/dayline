import XCTest
@testable import Dayline

final class ProbeStoreTests: XCTestCase {
    private var directory: URL!

    override func setUpWithError() throws {
        directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("dayline-tests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        if let directory {
            try? FileManager.default.removeItem(at: directory)
        }
    }

    func testRoundTripKeepsValues() throws {
        let snapshot = ProbeSnapshot(
            message: "xin chào",
            updatedAt: Date(timeIntervalSince1970: 1_700_000_000),
            appVersion: "0.1.0",
            buildNumber: "1"
        )

        try ProbeStore.write(snapshot, in: directory)

        XCTAssertEqual(ProbeStore.read(in: directory), snapshot)
    }

    func testWriteWithoutDirectoryThrowsAppGroupUnavailable() {
        let snapshot = ProbeSnapshot(message: "x", updatedAt: .now, appVersion: "1", buildNumber: "1")

        XCTAssertThrowsError(try ProbeStore.write(snapshot, in: nil)) { error in
            XCTAssertEqual(error as? ProbeStoreError, .appGroupUnavailable)
        }
    }

    func testReadWithoutDirectoryReturnsNil() {
        XCTAssertNil(ProbeStore.read(in: nil))
    }

    func testReadMissingFileReturnsNil() {
        XCTAssertNil(ProbeStore.read(in: directory))
    }

    func testWriteIsAtomicAndOverwrites() throws {
        try ProbeStore.write(.init(message: "lần 1", updatedAt: .now, appVersion: "0.1.0", buildNumber: "1"), in: directory)
        try ProbeStore.write(.init(message: "lần 2", updatedAt: .now, appVersion: "0.1.0", buildNumber: "1"), in: directory)

        XCTAssertEqual(ProbeStore.read(in: directory)?.message, "lần 2")
    }

    func testAppGroupIdentifierIsStable() {
        XCTAssertEqual(AppGroup.identifier, "group.com.ngia.dayline")
        XCTAssertEqual(AppInfo.appGroupIdentifier, AppGroup.identifier)
        XCTAssertEqual(AppInfo.widgetBundleIdentifier, "com.ngia.dayline.widgets")
    }

    func testAppGroupUnavailableDoesNotCrash() {
        // Không assert giá trị: tuỳ chứng chỉ (free ID → false).
        _ = AppGroup.isAvailable
        _ = AppGroup.statusText
    }
}
