import Foundation

enum ProbeStoreError: Error, Equatable {
    case appGroupUnavailable
}

/// Đọc/ghi `probe.json` trong một thư mục bất kỳ.
/// Tham số `directory` cho phép test bằng thư mục tạm (không phụ thuộc entitlement).
enum ProbeStore {
    static let fileName = "probe.json"

    static func fileURL(in directory: URL) -> URL {
        directory.appendingPathComponent(fileName, isDirectory: false)
    }

    static func write(_ snapshot: ProbeSnapshot, in directory: URL?) throws {
        guard let directory else { throw ProbeStoreError.appGroupUnavailable }
        let data = try DaylineCoding.encoder.encode(snapshot)
        try data.write(to: fileURL(in: directory), options: .atomic)
    }

    static func read(in directory: URL?) -> ProbeSnapshot? {
        guard let directory else { return nil }
        guard let data = try? Data(contentsOf: fileURL(in: directory)) else { return nil }
        return try? DaylineCoding.decoder.decode(ProbeSnapshot.self, from: data)
    }

    static func writeToSharedGroup(_ snapshot: ProbeSnapshot) throws {
        try write(snapshot, in: AppGroup.containerURL)
    }

    static var sharedSnapshot: ProbeSnapshot? {
        read(in: AppGroup.containerURL)
    }
}
