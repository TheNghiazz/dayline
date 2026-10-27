import Foundation

enum Priority: Int, Codable, CaseIterable, Comparable {
    case low = 0
    case normal = 1
    case high = 2

    static func < (lhs: Priority, rhs: Priority) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

/// Quy tắc lặp lại. Lưu vào SwiftData dưới dạng JSON string (`TaskItem.recurrenceRaw`)
/// để schema nhẹ và migrate dễ.
struct RecurrenceRule: Codable, Equatable {
    enum Kind: String, Codable {
        case daily
        case weekdays
        case everyNDays
    }

    var kind: Kind
    /// 1 = Chủ nhật ... 7 = Thứ bảy (Calendar.component(.weekday)).
    var weekdays: Set<Int>
    var interval: Int

    init(kind: Kind, weekdays: Set<Int> = [], interval: Int = 1) {
        self.kind = kind
        self.weekdays = weekdays
        self.interval = max(1, interval)
    }

    init?(encoded: String?) {
        guard let encoded, let data = encoded.data(using: .utf8) else { return nil }
        guard let value = try? JSONDecoder().decode(RecurrenceRule.self, from: data) else { return nil }
        self = value
    }

    var encodedString: String? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    static let daily = RecurrenceRule(kind: .daily)
}
