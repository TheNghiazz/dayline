import SwiftUI

/// Khung editor của P3: tên, ghi chú, giờ, thời lượng, ưu tiên.
/// P4 bổ sung lặp lại + nhắc nhở (và notification).
struct TaskEditorView: View {
    let task: TaskItem?
    let defaultStart: Date
    let onSave: (TaskDraft) -> Void
    let onDelete: (() -> Void)?

    @Environment(\.dismiss) private var dismiss
    @FocusState private var titleFocused: Bool

    @State private var title: String
    @State private var detail: String
    @State private var hasTime: Bool
    @State private var start: Date
    @State private var durationMinutes: Int
    @State private var priority: Priority

    init(
        task: TaskItem?,
        defaultStart: Date = .now,
        onSave: @escaping (TaskDraft) -> Void,
        onDelete: (() -> Void)? = nil
    ) {
        self.task = task
        self.defaultStart = defaultStart
        self.onSave = onSave
        self.onDelete = onDelete

        _title = State(initialValue: task?.title ?? "")
        _detail = State(initialValue: task?.detail ?? "")
        _hasTime = State(initialValue: task?.startAt != nil || task == nil)
        _start = State(initialValue: task?.startAt ?? defaultStart)
        _durationMinutes = State(initialValue: task?.durationMinutes ?? TaskItem.defaultDurationMinutes)
        _priority = State(initialValue: task?.priority ?? .normal)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Tên việc", text: $title, axis: .vertical)
                        .focused($titleFocused)
                        .font(DLFont.body)

                    TextField("Ghi chú", text: $detail, axis: .vertical)
                        .lineLimit(2...4)
                        .font(DLFont.body)
                }

                Section {
                    Toggle("Đặt giờ", isOn: $hasTime.animation())

                    if hasTime {
                        DatePicker(
                            "Bắt đầu",
                            selection: $start,
                            displayedComponents: .hourAndMinute
                        )

                        Picker("Thời lượng", selection: $durationMinutes) {
                            Text("15 phút").tag(15)
                            Text("30 phút").tag(30)
                            Text("45 phút").tag(45)
                            Text("1 giờ").tag(60)
                            Text("1,5 giờ").tag(90)
                            Text("2 giờ").tag(120)
                        }

                        LabeledContent("Kết thúc", value: endText)
                    }
                } header: {
                    Text("Thời gian")
                } footer: {
                    if !hasTime {
                        Text("Việc không đặt giờ sẽ không hiện ở tab Hôm nay.")
                    }
                }

                Section("Ưu tiên") {
                    Picker("Ưu tiên", selection: $priority) {
                        Text("Thấp").tag(Priority.low)
                        Text("Bình thường").tag(Priority.normal)
                        Text("Cao").tag(Priority.high)
                    }
                    .pickerStyle(.segmented)
                }

                if let onDelete {
                    Section {
                        Button("Xoá việc", role: .destructive) {
                            onDelete()
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle(task == nil ? "Việc mới" : "Sửa việc")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Huỷ") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Lưu") { save() }
                        .disabled(trimmedTitle.isEmpty)
                        .fontWeight(.semibold)
                }
            }
            .onAppear {
                if task == nil {
                    titleFocused = true
                }
            }
        }
    }

    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var endText: String {
        guard hasTime else { return "—" }
        let end = start.addingTimeInterval(TimeInterval(durationMinutes * 60))
        return DLDateText.time(end)
    }

    private func save() {
        let trimmedDetail = detail.trimmingCharacters(in: .whitespacesAndNewlines)

        var draft = TaskDraft(title: trimmedTitle)
        draft.detail = trimmedDetail.isEmpty ? nil : trimmedDetail
        draft.priority = priority
        if hasTime {
            draft.startAt = start
            draft.durationMinutes = durationMinutes
        }

        // Giữ nguyên phần P4 sẽ cho sửa (lặp lại, nhắc nhở) khi edit.
        draft.recurrence = task?.recurrence
        draft.reminderMinutesBefore = task?.reminderMinutesBefore

        onSave(draft)
        dismiss()
    }
}

#Preview("Việc mới") {
    TaskEditorView(task: nil, onSave: { _ in })
}
