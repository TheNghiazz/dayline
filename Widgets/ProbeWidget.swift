import SwiftUI
import WidgetKit

struct ProbeEntry: TimelineEntry {
    let date: Date
    let isShared: Bool
    let message: String
    let updatedAt: Date?

    static var placeholder: ProbeEntry {
        ProbeEntry(date: .now, isShared: true, message: "Họp review sprint", updatedAt: .now)
    }

    static var current: ProbeEntry {
        let snapshot = ProbeStore.sharedSnapshot
        return ProbeEntry(
            date: .now,
            isShared: snapshot != nil,
            message: snapshot?.message ?? "Chưa đồng bộ",
            updatedAt: snapshot?.updatedAt
        )
    }
}

struct ProbeProvider: TimelineProvider {
    func placeholder(in context: Context) -> ProbeEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (ProbeEntry) -> Void) {
        completion(.current)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ProbeEntry>) -> Void) {
        let entry = ProbeEntry.current
        let next = Calendar.current.date(byAdding: .minute, value: 15, to: .now)
            ?? Date.now.addingTimeInterval(15 * 60)
        completion(Timeline(entries: [entry], policy: .after(next)))
    }
}

struct ProbeWidgetView: View {
    @Environment(\.widgetFamily) private var family

    let entry: ProbeEntry

    var body: some View {
        content
            .containerBackground(for: .widget) {
                if family == .systemSmall {
                    Color(uiColor: .systemBackground)
                } else {
                    Color.clear
                }
            }
    }

    @ViewBuilder
    private var content: some View {
        switch family {
        case .systemSmall:
            VStack(alignment: .leading, spacing: 4) {
                Text("Dayline")
                    .font(.caption2.weight(.semibold))
                    .textCase(.uppercase)
                    .foregroundStyle(.secondary)

                Text(entry.isShared ? "App Group OK" : "Chưa đồng bộ")
                    .font(.headline)
                    .lineLimit(2)

                if let updatedAt = entry.updatedAt {
                    Text(updatedAt, style: .time)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Mở app để ghi dữ liệu")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)

        default:
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.isShared ? "APP GROUP OK" : "CHƯA ĐỒNG BỘ")
                    .font(.caption2.weight(.semibold))

                Text(entry.message)
                    .font(.headline)
                    .lineLimit(1)

                Text(subtitle)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var subtitle: String {
        guard let updatedAt = entry.updatedAt else {
            return "Mở app để ghi dữ liệu"
        }
        return "Cập nhật \(updatedAt.formatted(date: .omitted, time: .shortened))"
    }
}

struct ProbeWidget: Widget {
    private let kind = "ProbeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ProbeProvider()) { entry in
            ProbeWidgetView(entry: entry)
        }
        .configurationDisplayName("Dayline · Kiểm tra")
        .description("Xác nhận app và widget chia sẻ được dữ liệu qua App Group.")
        .supportedFamilies([.accessoryRectangular, .systemSmall])
    }
}
