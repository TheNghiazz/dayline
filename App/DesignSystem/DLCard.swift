import SwiftUI

/// Card phẳng: surface + viền hairline + radius 14 (đúng design system, không đổ bóng).
struct DLCard<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .background(DLColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: DLRadius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DLRadius.card, style: .continuous)
                .strokeBorder(DLColor.border, lineWidth: 1)
        )
    }
}

struct DLDivider: View {
    var body: some View {
        Rectangle()
            .fill(DLColor.border)
            .frame(height: 1)
            .padding(.leading, DLSpace.l)
    }
}

struct TodayEmptyState: View {
    var body: some View {
        VStack(spacing: DLSpace.s) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 32, weight: .light))
                .foregroundStyle(DLColor.text2)

            Text("Hôm nay trống")
                .font(DLFont.title)
                .foregroundStyle(DLColor.text)

            Text("Thêm việc đầu tiên để bắt đầu ngày.")
                .font(DLFont.meta)
                .foregroundStyle(DLColor.text2)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DLSpace.xxl)
    }
}

#Preview {
    VStack(spacing: 24) {
        DLCard {
            TaskRow(title: "Họp review sprint", timeText: "14:30 – 15:15", state: .current) {}
            DLDivider()
            TaskRow(title: "Viết API spec", timeText: "15:30 – 16:30", state: .upcoming) {}
        }
        TodayEmptyState()
    }
    .padding(DLSpace.margin)
    .background(DLColor.bg)
}
