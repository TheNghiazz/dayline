import SwiftUI

struct ProgressRing: View {
    let done: Int
    let total: Int
    var size: CGFloat = 44
    var lineWidth: CGFloat = 3

    private var progress: Double {
        guard total > 0 else { return 0 }
        return min(max(Double(done) / Double(total), 0), 1)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(DLColor.border, lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(DLColor.accentGradient, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.4), value: progress)

            Text("\(done)/\(total)")
                .font(.system(size: size * 0.28, weight: .semibold))
                .monospacedDigit()
                .foregroundStyle(DLColor.text)
        }
        .frame(width: size, height: size)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(done) trên \(total) việc đã xong")
    }
}

#Preview {
    HStack(spacing: 16) {
        ProgressRing(done: 2, total: 7, size: 44)
        ProgressRing(done: 5, total: 7, size: 64, lineWidth: 4)
        ProgressRing(done: 0, total: 0, size: 64, lineWidth: 4)
    }
    .padding(40)
    .background(DLColor.bg)
}
