import SwiftUI
import WidgetKit

/// P0: công cụ duy nhất để debug khi không có Xcode.
/// P6 mở rộng thành 6 dòng trạng thái + xuất log.
struct DiagnosticsView: View {
    @State private var isShared = AppGroup.isAvailable
    @State private var snapshot = ProbeStore.sharedSnapshot
    @State private var lastResult: String?

    var body: some View {
        List {
            Section("App Group") {
                LabeledContent("ID", value: AppGroup.identifier)
                LabeledContent("Trạng thái", value: isShared ? "Đã kết nối" : "Không khả dụng")
                LabeledContent("Probe", value: snapshot == nil ? "Chưa có" : "Đã đọc được")
            }

            Section("Đường dẫn container") {
                Text(AppGroup.containerURL?.path ?? "— (nil)")
                    .font(.footnote)
                    .textSelection(.enabled)
                    .foregroundStyle(.secondary)
            }

            Section("Widget") {
                LabeledContent("Extension", value: AppInfo.widgetBundleIdentifier)
            }

            Section("Phiên bản") {
                LabeledContent("App", value: AppInfo.displayVersion)
                LabeledContent("Bundle", value: AppInfo.bundleIdentifier)
            }

            Section {
                Button("Ghi lại probe rồi reload widget") {
                    let ok = ProbeRecorder.record(message: "probe từ Chẩn đoán")
                    lastResult = ok
                        ? "Đã ghi probe và yêu cầu widget reload."
                        : "Không ghi được: App Group chưa được cấp."
                    refresh()
                }

                Button("Chỉ reload widget") {
                    WidgetCenter.shared.reloadAllTimelines()
                    lastResult = "Đã gửi yêu cầu reload timeline."
                }
            } footer: {
                if let lastResult {
                    Text(lastResult)
                }
            }
        }
        .navigationTitle("Chẩn đoán")
        .onAppear(perform: refresh)
    }

    private func refresh() {
        isShared = AppGroup.isAvailable
        snapshot = ProbeStore.sharedSnapshot
    }
}

#Preview {
    NavigationStack {
        DiagnosticsView()
    }
}
