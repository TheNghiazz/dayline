import SwiftUI

/// Nút nổi "+ Thêm việc": nơi duy nhất được phép đổ bóng trong design system.
struct DLFloatingButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DLFont.button)
            .foregroundStyle(DLColor.onAccent)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Capsule().fill(DLColor.accent))
            .shadow(color: .black.opacity(0.10), radius: 16, y: 4)
            .opacity(configuration.isPressed ? 0.85 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct DLPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DLFont.button)
            .foregroundStyle(DLColor.onAccent)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                RoundedRectangle(cornerRadius: DLRadius.card, style: .continuous)
                    .fill(DLColor.accent)
            )
            .opacity(configuration.isPressed ? 0.85 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

#Preview {
    VStack(spacing: 16) {
        Button {
        } label: {
            Label("Thêm việc", systemImage: "plus")
        }
        .buttonStyle(DLFloatingButtonStyle())

        Button {
        } label: {
            Text("Lưu việc")
        }
        .buttonStyle(DLPrimaryButtonStyle())
    }
    .padding(DLSpace.margin)
    .background(DLColor.bg)
}
