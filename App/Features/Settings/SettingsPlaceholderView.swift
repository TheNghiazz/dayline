import SwiftUI

/// P0: placeholder. P6 cắt theo `07_settings` xuống còn 3 nhóm.
struct SettingsPlaceholderView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Dữ liệu") {
                    NavigationLink {
                        DiagnosticsView()
                    } label: {
                        Label("Chẩn đoán", systemImage: "stethoscope")
                    }
                }

                Section {
                    LabeledContent("Dayline", value: AppInfo.displayVersion)
                } footer: {
                    Text("P6 sẽ bổ sung nhắc nhở, ngôn ngữ, giao diện, xuất/nhập dữ liệu.")
                }
            }
            .navigationTitle("Cài đặt")
        }
    }
}

#Preview {
    SettingsPlaceholderView()
}
