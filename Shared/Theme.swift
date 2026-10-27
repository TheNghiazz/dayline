import SwiftUI
import UIKit

// MARK: - Token màu (đọc từ design/design-system.md)

extension Color {
    /// Màu tự đổi theo light/dark. Không dùng `if colorScheme` trong view.
    init(light: UInt32, dark: UInt32) {
        self.init(uiColor: UIColor { traits in
            UIColor(hex: traits.userInterfaceStyle == .dark ? dark : light)
        })
    }

    init(hex: UInt32) {
        self.init(uiColor: UIColor(hex: hex))
    }
}

private extension UIColor {
    convenience init(hex: UInt32) {
        let red = CGFloat((hex >> 16) & 0xFF) / 255
        let green = CGFloat((hex >> 8) & 0xFF) / 255
        let blue = CGFloat(hex & 0xFF) / 255
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
}

enum DLColor {
    static let bg = Color(light: 0xF7F7F5, dark: 0x0E0F0E)
    static let surface = Color(light: 0xFFFFFF, dark: 0x1A1C1A)
    static let surface2 = Color(light: 0xF0F0ED, dark: 0x242724)
    static let text = Color(light: 0x1A1A1A, dark: 0xF2F2F2)
    static let text2 = Color(light: 0x6B6B6B, dark: 0xA0A5A1)
    static let border = Color(light: 0xE6E6E2, dark: 0x2E322E)
    /// Viền control nhỏ (checkbox, ô chưa chọn) — đậm hơn `border` để thấy rõ ở dark mode.
    static let controlLine = Color(light: 0xCFCFC9, dark: 0x4B504B)

    static let accent = Color(light: 0x2F6B4F, dark: 0x6DBE97)
    static let accentHigh = Color(light: 0x529975, dark: 0x8CD3AF)
    static let accentBG = Color(light: 0xE7F0EA, dark: 0x1E2B24)

    /// Chữ/biểu tượng đặt trên nền `accent` (dark mode accent là màu sáng → chữ phải tối).
    static let onAccent = Color(light: 0xFFFFFF, dark: 0x0B1F16)

    static let success = Color(hex: 0x34A853)
    static let warning = Color(hex: 0xE8A33D)
    static let danger = Color(hex: 0xD9534F)

    static var accentGradient: AngularGradient {
        AngularGradient(colors: [accent, accentHigh], center: .center)
    }
}

// MARK: - Typography

enum DLFont {
    static let display = Font.system(size: 28, weight: .bold)
    static let title = Font.system(size: 22, weight: .semibold)
    static let section = Font.system(size: 13, weight: .semibold)
    static let body = Font.system(size: 17, weight: .regular)
    static let bodyEmphasis = Font.system(size: 17, weight: .semibold)
    static let meta = Font.system(size: 13, weight: .regular)
    static let time = Font.system(size: 15, weight: .semibold).monospacedDigit()
    static let button = Font.system(size: 17, weight: .semibold)
    static let caption = Font.system(size: 11, weight: .medium)
}

// MARK: - Spacing & radius

enum DLSpace {
    static let xs: CGFloat = 4
    static let s: CGFloat = 8
    static let m: CGFloat = 12
    static let l: CGFloat = 16
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
    static let margin: CGFloat = 20
}

enum DLRadius {
    static let input: CGFloat = 10
    static let card: CGFloat = 14
    static let sheet: CGFloat = 18
}
