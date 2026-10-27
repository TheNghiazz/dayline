import SwiftUI

struct RootTabView: View {
    enum Tab: Hashable {
        case today
        case notes
        case settings
    }

    @State private var selection: Tab = .today

    var body: some View {
        TabView(selection: $selection) {
            TodayPlaceholderView()
                .tabItem { Label("Hôm nay", systemImage: "clock") }
                .tag(Tab.today)

            NotesPlaceholderView()
                .tabItem { Label("Ghi chú", systemImage: "note.text") }
                .tag(Tab.notes)

            SettingsPlaceholderView()
                .tabItem { Label("Cài đặt", systemImage: "gearshape") }
                .tag(Tab.settings)
        }
    }
}

#Preview {
    RootTabView()
}
