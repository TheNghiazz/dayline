import SwiftUI

/// P0: màn tạm để xác nhận hạ tầng (App Group, build, widget).
/// P1 thay bằng timeline thật theo `stitch_smooth_motion_plan_animation/02_today_timeline`.
struct TodayPlaceholderView: View {
    @State private var isShared = AppGroup.isAvailable
    @State private var snapshot = ProbeStore.sharedSnapshot

    var body: some View {
        NavigationStack {
            List {
                Section {
                    LabeledContent("App Group", value: isShared ? "Đã kết nối" : "Không khả dụng")
                    LabeledContent("Probe", value: snapshot == nil ? "Chưa có" : "Đã đọc được")
                    LabeledContent("Phiên bản", value: AppInfo.displayVersion)
                    LabeledContent("Bundle", value: AppInfo.bundleIdentifier)
                } header: {
                    Text("P0 · Kiểm tra hạ tầng")
                } footer: {
                    Text(isShared
                         ? "App Group hoạt động: widget sẽ đọc được dữ liệu."
                         : "App Group không khả dụng (thường gặp với Apple ID free). App vẫn chạy, widget sẽ hiện trạng thái chưa đồng bộ.")
                }

                Section("Bước tiếp theo") {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("P1 · Theme, component, màn Hôm nay", systemImage: "paintbrush")
                        Label("P2 · SwiftData + repository", systemImage: "cylinder.split.1x2")
                        Label("P7 · Widget thật (6 surface)", systemImage: "square.grid.2x2")
                    }
                    .foregroundStyle(.secondary)
                }

                Section {
                    Button("Ghi lại probe") {
                        ProbeRecorder.record()
                        refresh()
                    }
                }
            }
            .navigationTitle("Hôm Nay")
            .onAppear(perform: refresh)
        }
    }

    private func refresh() {
        isShared = AppGroup.isAvailable
        snapshot = ProbeStore.sharedSnapshot
    }
}

#Preview {
    TodayPlaceholderView()
}
