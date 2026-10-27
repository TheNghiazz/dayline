import Foundation

enum DLDateText {
    /// "Thứ Ba, 27 tháng 10" (vi) hoặc "Tuesday, October 27" (en).
    static func dayTitle(for date: Date = .now, locale: Locale = .current) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.setLocalizedDateFormatFromTemplate("EEEEdMMMM")
        return formatter.string(from: date)
    }

    static func time(_ date: Date, locale: Locale = .current) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.setLocalizedDateFormatFromTemplate("jm")
        return formatter.string(from: date)
    }

    static func timeRange(from start: Date, to end: Date, locale: Locale = .current) -> String {
        "\(time(start, locale: locale)) – \(time(end, locale: locale))"
    }
}
