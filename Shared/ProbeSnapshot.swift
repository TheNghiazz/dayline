import Foundation

/// Snapshot nhỏ mà app ghi vào App Group để widget đọc.
/// P0 chỉ dùng để kiểm tra đường truyền; P7 mở rộng thành dữ liệu task thật.
struct ProbeSnapshot: Codable, Equatable {
    var message: String
    var updatedAt: Date
    var appVersion: String
    var buildNumber: String
}

enum DaylineCoding {
    static var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }

    static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
