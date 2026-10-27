import SwiftUI
import UIKit

struct TodayView: View {
    @State private var tasks: [TodayTask]
    @State private var completedExpanded = true

    init(tasks: [TodayTask] = TodayTask.sample()) {
        _tasks = State(initialValue: tasks)
    }

    var body: some View {
        let now = Date.now
        let completed = tasks.filter(\.isDone)
        let current = tasks.first { !$0.isDone && $0.state(at: now) == .current }
        let upcoming = tasks
            .filter { !$0.isDone && $0.id != current?.id }
            .sorted { $0.start < $1.start }

        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DLSpace.xl) {
                    header(completed: completed.count, total: tasks.count)

                    if tasks.isEmpty {
                        TodayEmptyState()
                    } else {
                        if let current {
                            section(title: "ĐANG LÀM", accentDot: true) {
                                DLCard {
                                    row(for: current)
                                }
                            }
                        }

                        if !upcoming.isEmpty {
                            section(title: "SẮP TỚI", count: upcoming.count) {
                                DLCard {
                                    rows(upcoming)
                                }
                            }
                        }

                        if !completed.isEmpty {
                            section(title: "ĐÃ XONG", count: completed.count, collapsible: true) {
                                if completedExpanded {
                                    DLCard {
                                        rows(completed)
                                    }
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
                Button {
                    // P4: mở TaskEditorView
                } label: {
                    Label("Thêm việc", systemImage: "plus")
                }
                .buttonStyle(DLFloatingButtonStyle())
                .padding(.horizontal, DLSpace.margin)
                .padding(.bottom, DLSpace.s)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    // MARK: - Pieces

    private func header(completed: Int, total: Int) -> some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: DLSpace.xs) {
                Text(DLDateText.dayTitle())
                    .font(DLFont.meta)
                    .foregroundStyle(DLColor.text2)

                Text("Hôm Nay")
                    .font(DLFont.display)
                    .foregroundStyle(DLColor.text)
            }

            Spacer(minLength: DLSpace.m)

            ProgressRing(done: completed, total: total, size: 44, lineWidth: 3)
        }
        .padding(.top, DLSpace.m)
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

    private func rows(_ items: [TodayTask]) -> some View {
        ForEach(items) { task in
            row(for: task)
            if task.id != items.last?.id {
                DLDivider()
            }
        }
    }

    private func row(for task: TodayTask) -> some View {
        TaskRow(
            title: task.title,
            timeText: task.timeText,
            state: task.state(at: .now)
        ) {
            toggle(task)
        }
    }

    // MARK: - Actions

    private func collapseCompleted() {
        withAnimation(.easeOut(duration: 0.2)) {
            completedExpanded.toggle()
        }
    }

    private func toggle(_ task: TodayTask) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        withAnimation(.spring(response: 0.28, dampingFraction: 0.8)) {
            tasks[index].isDone.toggle()
        }
    }
}

#Preview("Có việc") {
    TodayView()
}

#Preview("Trống") {
    TodayView(tasks: [])
}

#Preview("Dark") {
    TodayView()
        .preferredColorScheme(.dark)
}
