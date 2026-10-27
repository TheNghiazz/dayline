import SwiftUI

/// P0: placeholder. P5 dựng theo `05_notes_list` + `06_note_editor`.
struct NotesPlaceholderView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Chưa có ghi chú",
                systemImage: "note.text",
                description: Text("P5 sẽ dựng danh sách và trình soạn ghi chú.")
            )
            .navigationTitle("Ghi chú")
        }
    }
}

#Preview {
    NotesPlaceholderView()
}
