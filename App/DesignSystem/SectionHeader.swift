import SwiftUI

struct SectionHeader: View {
    let title: String
    var count: Int? = nil
    var accentDot: Bool = false
    var isCollapsible: Bool = false
    var isExpanded: Bool = true
    var onToggle: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: DLSpace.s) {
            Text(label)
                .font(DLFont.section)
                .tracking(0.6)
                .foregroundStyle(DLColor.text2)

            if accentDot {
                Circle()
                    .fill(DLColor.accent)
                    .frame(width: 6, height: 6)
                    .accessibilityHidden(true)
            }

            Spacer(minLength: 0)

            if isCollapsible {
                Button {
                    onToggle?()
                } label: {
                    Image(systemName: "chevron.up")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(DLColor.text2)
                        .rotationEffect(.degrees(isExpanded ? 0 : 180))
                        .animation(.easeOut(duration: 0.2), value: isExpanded)
                        .frame(width: 32, height: 32)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isExpanded ? "Thu gọn mục đã xong" : "Mở rộng mục đã xong")
            }
        }
    }

    private var label: String {
        guard let count else { return title }
        return "\(title) (\(count))"
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 16) {
        SectionHeader(title: "ĐANG LÀM", accentDot: true)
        SectionHeader(title: "SẮP TỚI", count: 4)
        SectionHeader(title: "ĐÃ XONG", count: 2, isCollapsible: true, isExpanded: true)
        SectionHeader(title: "ĐÃ XONG", count: 2, isCollapsible: true, isExpanded: false)
    }
    .padding(DLSpace.margin)
    .background(DLColor.bg)
}
