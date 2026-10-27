import Combine
import SwiftUI
import UIKit

struct TodayView: View {
    @State private var store: TodayStore
    @State private var completedExpanded = true
    @State private var pendingDelete: TaskItem?
    @State private var editorTarget: EditorTarget?

    init(store: TodayStore? = nil) {
        _store = State(initialValue: store ?? TodayStore(repository: AppRepositories.tasks))
    }

    var body: some View {
        let data = store.aggregate

        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DLSpace.xl) {
                    header(done: data.doneCount, total: data.total)

                    if let message = store.errorMessage {
                        errorBanner(message)
                    }

                    if data.isEmpty {
                        TodayEmptyState()
                            .padding(.top, DLSpace.xl)
                    } else {
                        if !data.running.isEmpty {
                            section(title: "ĐANG LÀM", accentDot: true) {
                                DLCard { rows(data.running) }
                            }
                        }

                        if !data.overdue.isEmpty {
                            section(title: "QUÁ HẠN", count: data.overdue.count) {
                                DLCard { rows(data.overdue) }
                            }
                        }

                        if !data.upcoming.isEmpty {
                            section(title: "SẮP TỚI", count: data.upcoming.count) {
                                DLCard { rows(data.upcoming) }
                            }
                        }

                        if !data.done.isEmpty {
                            section(title: "ĐÃ XONG", count: data.done.count, collapsible: true) {
                                if completedExpanded {
                                    DLCard { rows(data.done) }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, DLSpace.margin)
                .padding(.top, DLSpace.s)
                .padding(.bottom, DLSpace.xl)
            }
            .background { DLColor.bg.ignoresSafeArea() }
            .safeAreaInset(edge: .bottom) {
                addButton
            }
            .toolbar(.hidden, for: .navigationBar)
            .task {
                await store.runClock()
            }
            .onReceive(NotificationCenter.default.publisher(for: .daylineDataChanged)) { _ in
                store.load()
            }
            .sheet(item: $editorTarget) { target in
                TaskEditorView(
                    task: target.task,
                    defaultStart: target.defaultStart,
                    onSave: { draft in
                        store.save(draft, editing: target.task)
                    },
                    onDelete: deleteAction(for: target.task)
                )
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
            .confirmationDialog(
                "Xoá việc này?",
                isPresented: deleteDialogBinding,
                titleVisibility: .visible,
                presenting: pendingDelete
            ) { task in
                Button("Xoá", role: .destructive) {
                    withAnimation(.easeOut(duration: 0.2)) {
                        store.delete(task)
                    }
                    pendingDelete = nil
                }
            } message: { task in
                Text(task.title)
            }
        }
    }

    // MARK: - Pieces

    private var addButton: some View {
        Button {
            editorTarget = EditorTarget(task: nil, defaultStart: Self.nextSlot(after: store.now))
        } label: {
            Label("Thêm việc", systemImage: "plus")
        }
        .buttonStyle(DLFloatingButtonStyle())
        .padding(.horizontal, DLSpace.margin)
        .padding(.bottom, DLSpace.s)
    }

    private func header(done: Int, total: Int) -> some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: DLSpace.xs) {
                Text(DLDateText.dayTitle(for: store.now))
                    .font(DLFont.meta)
                    .foregroundStyle(DLColor.text2)

                Text("Hôm Nay")
                    .font(DLFont.display)
                    .foregroundStyle(DLColor.text)
            }

            Spacer(minLength: DLSpace.m)

            ProgressRing(done: done, total: total, size: 44, lineWidth: 3)
        }
        .padding(.top, DLSpace.m)
    }

    private func errorBanner(_ message: String) -> some View {
        HStack(alignment: .top, spacing: DLSpace.s) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(DLColor.warning)

            Text(message)
                .font(DLFont.meta)
                .foregroundStyle(DLColor.text2)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(DLSpace.m)
        .background(DLColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: DLRadius.card, style: .continuous))
    }

    private func section<Content: View>(
        title: String,
        count: Int? = nil,
        accentDot: Bool = false,
        collapsible: Bool = false,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: DLSpace.m) {
            SectionHeader(
                title: title,
                count: count,
                accentDot: accentDot,
                isCollapsible: collapsible,
                isExpanded: completedExpanded,
                onToggle: collapseCompleted
            )
            content()
        }
    }

    private func rows(_ items: [TaskItem]) -> some View {
        ForEach(items) { task in
            row(for: task)
            if task.id != items.last?.id {
                DLDivider()
            }
        }
    }

    private func row(for task: TaskItem) -> some View {
        TaskRow(
            title: task.title,
            timeText: task.displayTimeText,
            state: task.rowState(at: store.now),
            onSelect: {
                editorTarget = EditorTarget(task: task, defaultStart: task.startAt ?? store.now)
            }
        ) {
            toggle(task)
        }
        .contextMenu {
            Button {
                editorTarget = EditorTarget(task: task, defaultStart: task.startAt ?? store.now)
            } label: {
                Label("Sửa", systemImage: "pencil")
            }

            Button(role: .destructive) {
                pendingDelete = task
            } label: {
                Label("Xoá", systemImage: "trash")
            }
        }
    }

    // MARK: - Actions

    private var deleteDialogBinding: Binding<Bool> {
        Binding(
            get: { pendingDelete != nil },
            set: { if !$0 { pendingDelete = nil } }
        )
    }

    private func collapseCompleted() {
        withAnimation(.easeOut(duration: 0.2)) {
            completedExpanded.toggle()
        }
    }

    private func deleteAction(for task: TaskItem?) -> (() -> Void)? {
        guard let task else { return nil }
        return { store.delete(task) }
    }

    private func toggle(_ task: TaskItem) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        withAnimation(.spring(response: 0.28, dampingFraction: 0.8)) {
            store.toggle(task)
        }
    }

    /// Mốc 5 phút kế tiếp, để việc mới không rơi vào giờ đã qua.
    static func nextSlot(after date: Date, calendar: Calendar = .current) -> Date {
        let base = calendar.date(bySetting: .second, value: 0, of: date) ?? date
        let minute = calendar.component(.minute, from: base)
        let delta = 5 - (minute % 5)
        return calendar.date(byAdding: .minute, value: delta, to: base) ?? base
    }
}

private struct EditorTarget: Identifiable {
    let id = UUID()
    let task: TaskItem?
    let defaultStart: Date
}

#Preview("Có việc") {
    TodayView(store: TodayStore(repository: MockTaskRepository()))
}

#Preview("Trống") {
    TodayView(store: TodayStore(repository: MockTaskRepository(items: [])))
}

#Preview("Dark") {
    TodayView(store: TodayStore(repository: MockTaskRepository()))
        .preferredColorScheme(.dark)
}
