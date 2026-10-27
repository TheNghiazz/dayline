import SwiftUI

enum TaskRowState: Equatable {
    case current
    case upcoming
    case done
    case overdue
}

/// Một dòng công việc. Bố cục chốt theo ảnh Stitch:
/// thanh accent 3pt (task đang chạy) · title · giờ dưới title · checkbox bên phải.
struct TaskRow: View {
    let title: String
    let timeText: String
    let state: TaskRowState
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: DLSpace.m) {
            Capsule()
                .fill(state == .current ? DLColor.accent : Color.clear)
                .frame(width: 3, height: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(DLFont.body)
                    .foregroundStyle(DLColor.text)
                    .strikethrough(state == .done, color: DLColor.text2)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                HStack(spacing: 4) {
                    Text(timeText)
                        .font(DLFont.time)
                        .foregroundStyle(state == .overdue ? DLColor.warning : DLColor.text2)

                    if state == .overdue {
                        Image(systemName: "exclamationmark.circle.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(DLColor.warning)
                    }
                }
            }

            Spacer(minLength: DLSpace.s)

            Button(action: onToggle) {
                checkbox
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(state == .done ? "Bỏ đánh dấu hoàn thành" : "Đánh dấu hoàn thành")
        }
        .padding(.horizontal, DLSpace.l)
        .padding(.vertical, DLSpace.m)
        .frame(minHeight: 56)
        .opacity(state == .done ? 0.55 : 1)
    }

    private var checkbox: some View {
        ZStack {
            Circle()
                .fill(state == .done ? DLColor.accent : Color.clear)

            Circle()
                .strokeBorder(state == .done ? Color.clear : DLColor.border, lineWidth: 1.5)

            if state == .done {
                Image(systemName: "checkmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(DLColor.onAccent)
            }
        }
        .frame(width: 22, height: 22)
    }
}

#Preview {
    VStack(spacing: 0) {
        TaskRow(title: "Họp review sprint", timeText: "14:30 – 15:15", state: .current) {}
        DLDivider()
        TaskRow(title: "Viết API spec cho backend, mô tả endpoint và schema trả về", timeText: "15:30 – 16:30", state: .upcoming) {}
        DLDivider()
        TaskRow(title: "Chạy bộ công viên 3km", timeText: "17:30 – 18:00", state: .overdue) {}
        DLDivider()
        TaskRow(title: "Đọc tài liệu SwiftUI 18", timeText: "10:30 – 11:15", state: .done) {}
    }
    .background(DLColor.surface)
    .clipShape(RoundedRectangle(cornerRadius: DLRadius.card, style: .continuous))
    .overlay(
        RoundedRectangle(cornerRadius: DLRadius.card, style: .continuous)
            .strokeBorder(DLColor.border, lineWidth: 1)
    )
    .padding(DLSpace.margin)
    .background(DLColor.bg)
}
