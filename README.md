# Dayline

App iOS cá nhân: ghi chú + việc cần làm theo giờ trong ngày, có widget Lock Screen.

- **Thiết bị**: iPhone 12 Pro Max (iPhone13,4) · iOS 18.6 · deployment target iOS 17.0
- **Stack**: SwiftUI + SwiftData + WidgetKit + ActivityKit
- **Build**: GitHub Actions (macOS runner) → `.ipa` unsigned → Sideloadly (Apple ID free)
- **Bundle**: `com.ngia.dayline` · widget `com.ngia.dayline.widgets` · App Group `group.com.ngia.dayline`
- **Ngôn ngữ**: Tiếng Việt + English

## Trạng thái

Đang ở **P0**: kiểm tra hạ tầng (build, cài, widget extension, App Group).

Lộ trình đầy đủ: `IMPLEMENTATION_PLAN.md`. Bộ UI đã lọc: `design/screen-inventory.md`.

## Cấu trúc

```
project.yml                 # XcodeGen — nguồn sự thật, KHÔNG commit .xcodeproj
App/                        # app target (DaylineApp, RootTabView, Features/*)
Widgets/                    # widget extension (P0: ProbeWidget)
Shared/                     # code dùng chung app + widget
Resources/Assets.xcassets   # AppIcon + AccentColor
Tests/                      # unit test (chạy trên simulator ở CI)
Support/                    # Info.plist + entitlements, sinh tự động bởi XcodeGen
design/                     # design system + inventory + ghi chú lệch UI
.github/workflows/ci.yml    # build + unit test + screenshot
.github/workflows/release.yml # build unsigned IPA + artifact/Release
```

## Build trên GitHub Actions

1. Tạo repo **public** tên `dayline` trên GitHub.
2. Push code:
   ```bash
   git remote add origin https://github.com/<username>/dayline.git
   git push -u origin main
   ```
3. Mỗi lần push: workflow `ci` chạy unit test và chụp screenshot 2 chế độ (artifact `ui-screenshots`).
4. Muốn lấy IPA: **Actions → release-ipa → Run workflow** (hoặc push tag `v0.1.0`).

## Cài lên iPhone

1. Actions → run `release-ipa` → tải artifact `Dayline-ipa` → giải nén được `Dayline.ipa`.
2. Cài **Sideloadly** trên Windows, cắm iPhone, nhập Apple ID (2FA), kéo `Dayline.ipa` vào → Start.
3. iPhone → Settings → General → VPN & Device Management → Trust.
4. Thêm widget: giữ màn hình khoá → **Customize** → chọn ô widget → **Dayline**.

Giới hạn Apple ID free: app hết hạn sau **7 ngày**, tối đa **3 app**, **10 App ID mới/tuần** (app + widget = 2). Dùng AltServer/SideStore để tự refresh khi cùng Wi-Fi.

## P0 kiểm tra gì

Mở app → tab **Hôm Nay** hiển thị trạng thái App Group; mở **Cài đặt → Chẩn đoán** để xem container path và ghi lại probe.

| Kết quả | Nghĩa |
|---|---|
| `App Group: Đã kết nối` + widget hiện "APP GROUP OK" | Entitlement được cấp — widget sẽ có dữ liệu (bình thường cần Apple Developer Program) |
| `App Group: Không khả dụng` + widget hiện "CHƯA ĐỒNG BỘ" | Đúng như dự kiến với Apple ID free. App vẫn dùng bình thường; widget thật sẽ cần TK $99 (P7 quyết định) |

Widget P0 hỗ trợ `accessoryRectangular` (Lock Screen) và `systemSmall` (Home Screen).

## Ghi chú dev

- Không có Xcode trên Windows → mọi thứ kiểm tra qua CI. Nếu CI đỏ, đọc log job `test`.
- `Dayline.xcodeproj` và `Support/*` là file sinh tự động, đã nằm trong `.gitignore`.
- Không sửa file trong `stitch_smooth_motion_plan_animation/` — chỉ đọc làm tham chiếu.
- Font trong ảnh Stitch bị fallback serif; app luôn dùng SF Pro.
