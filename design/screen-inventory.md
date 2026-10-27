# Screen inventory — lọc bộ UI Stitch cho bản dùng cá nhân

Nguồn: `stitch_smooth_motion_plan_animation/` (11 màn + DESIGN.md)
Nguyên tắc lọc: **app chỉ để một người dùng** → bỏ mọi thứ thuộc về "sản phẩm": giới thiệu, hướng dẫn, mời đánh giá, iCloud, thống kê, onboarding.

---

## 1. Kết luận: bộ UI cuối cùng

**5 màn hình + 2 sheet + 6 widget surface** (thay vì 12)

| # | Màn | Nguồn Stitch | Vai trò |
|---|---|---|---|
| 1 | **Hôm nay** (timeline) | `02_today_timeline` | Tab chính |
| 2 | **Ghi chú** (list) | `05_notes_list` | Tab 2 |
| 3 | **Soạn ghi chú** | `06_note_editor` | Push từ tab 2 |
| 4 | **Cài đặt** | `07_settings` | Tab 3 (đã cắt ~50% nội dung) |
| 5 | **Chẩn đoán** | `10_ch_n_o_n_h_th_ng` | Sheet nhỏ, chỉ để debug sideload |
| S1 | **Việc mới / sửa việc** | `04_task_editor_sheet` | Sheet |
| S2 | **Chọn giờ** | (hệ thống) | `.graphical` DatePicker |
| W | **Lock screen:** inline / circular / rectangular | `11_lock_screen_widget_mockup` | WidgetKit |
| W | **Home screen:** small / medium | `11_lock_screen_widget_mockup` | WidgetKit |
| W | **Live Activity** (Lock Screen only) | `12_live_activity` | ActivityKit |

Tổng cộng 3 tab: **Hôm nay · Ghi chú · Cài đặt**. Không còn tab Thống kê.

---

## 2. Bảng quyết định từng folder

| Folder | Quyết định | Lý do |
|---|---|---|
| `01_style_guide_tokens` | **Giữ — reference** | Không phải màn hình; dùng để sinh `Theme.swift` |
| `02_today_timeline` | **Giữ — màn 1** | Màn lõi, dùng hằng ngày |
| `03_task_row_variants` | **Giữ — reference component** | Chỉ là bảng biến thể task row, không phải màn |
| `04_task_editor_sheet` | **Giữ — sheet** | Cần để tạo/sửa việc |
| `05_notes_list` | **Giữ — màn 2** | Có note + search + pin |
| `06_note_editor` | **Giữ — màn 3** | Soạn markdown |
| `07_settings` | **Giữ — màn 4 (cắt mạnh)** | Xem §4 |
| `09_h_ng_d_n_widget_ios_18` | **BỎ** | Đây là *trang hướng dẫn thêm widget* — bạn tự biết cách thêm widget. Toàn bộ nội dung "3 bước thiết lập", "tối ưu cho iOS 18", "StandBy" là tài liệu marketing, không phải tính năng |
| `10_ch_n_o_n_h_th_ng` | **BỎ màn — giữ 1 phần** | Màn "trạng thái App Group v1.2.0 / sẵn sàng build IPA" là bảng demo, không dành cho người dùng cuối. Chỉ giữ 6 dòng trạng thái + nút xuất log, đưa vào sheet Chẩn đoán |
| `11_lock_screen_widget_mockup` | **Giữ — reference widget** | Mockup 3 widget + toggle Standard/Tinted, cần cho code |
| `12_live_activity` | **Giữ — reference Live Activity** | Mockup + spec `ActivityAttributes` |
| `calm_native_productivity/DESIGN.md` | **Giữ** | Nguồn token chính thức |

Bị loại khỏi phạm vi (không cần vẽ lại): onboarding, đăng nhập/tài khoản, paywall, mời đánh giá App Store, chia sẻ, thống kê/biểu đồ, hướng dẫn sử dụng, màn "about" riêng.

---

## 3. Phải sửa trong các màn giữ lại

### 3.1. `02_today_timeline` — Hôm nay

- **Bỏ** nút avatar tròn góc phải (app cá nhân, không có tài khoản) → thay bằng **vòng tiến độ 40pt** "3/7" đúng như DESIGN.md (ảnh Stitch đang thiếu, chỗ đó lại là avatar).
- **Bỏ** chữ "Hôm Nay" bị lặp mờ phía sau (artifact của Stitch).
- **Bỏ** tab **Thống kê** (không có màn nào được thiết kế cho nó).
- Giữ: section ĐANG LÀM / SẮP TỚI / ĐÃ XONG (collapsible), thanh accent 3px cho task đang chạy, checkbox tròn bên phải, nút nổi "+ Thêm việc".
- **Thêm state chưa có:** `empty` (chưa có việc → "Hôm nay trống" + nút thêm), `quá hạn` (giờ đã qua, chưa tick → giờ màu `warning`).
- Đổi icon tab Hôm nay: `sun.max` → `clock` (đồng bộ với widget), hoặc giữ `sun.max` nếu bạn thích.

### 3.2. `04_task_editor_sheet`

- Giữ: tiêu đề lớn, hàng "Bắt đầu" + badge giờ, chip thời lượng 15/30/45/60, "Lặp lại", "Nhắc trước", ô ghi chú, nút Lưu.
- **Bỏ** card gợi ý "Thời gian hoàn hảo không trùng lịch…" — là tính năng AI gợi ý, không có trong scope và không cần cho 1 người dùng.
- **Bỏ** subtitle ngày "Thứ Năm, 24 tháng 10" nếu trùng với header (giữ nếu bạn muốn thấy ngày đang sửa).
- **Sửa:** footer đang bị tab bar che → dùng `.safeAreaInset(edge: .bottom)`; nút "Huỷ" hiện bị cắt chữ ("Huỷ" nằm dưới tab bar).

### 3.3. `05_notes_list`

- **Bỏ** tiêu đề giả "05 — Notes List" (label của Stitch) và avatar góc phải.
- Giữ: search, section ĐÃ GHIM, section TẤT CẢ, preview 2 dòng, icon pin.
- **Thêm:** state "không tìm thấy kết quả" cho search.
- Bỏ menu sắp xếp "Thời gian" nếu không muốn (mặc định sắp theo `updatedAt` giảm dần).

### 3.4. `06_note_editor`

- **Bỏ** nhãn "06 — Note Editor" trên nav.
- **Bỏ** toolbar ảnh/code/link (`image`, `code`, `link`) → chỉ giữ **H2 · B · I · Checklist · Bullet · Pin**. Ảnh cần asset store + export/import, không đáng cho bản cá nhân.
- Giữ block cảnh báo viền trái và block code (read-only trong preview) nếu muốn; nếu cắt thì bỏ luôn parser.
- **Sửa:** toolbar đang bị bàn phím che 1 phần → dùng `.safeAreaInset(edge: .bottom)` gắn với keyboard.

### 3.5. `07_settings` — cắt từ 5 nhóm xuống 3

**Giữ:**

| Nhóm | Dòng |
|---|---|
| Thông báo | Nhắc nhở công việc (toggle) · Tổng kết ngày (giờ) |
| Giao diện | Ngôn ngữ (Tiếng Việt / English) · Chế độ giao diện (Hệ thống / Sáng / Tối) |
| Dữ liệu | Xuất dữ liệu (JSON + Markdown) · Nhập dữ liệu · Chẩn đoán (App Group, widget, notification) |

**Bỏ:**

- `Đồng bộ iCloud` — không dùng CloudKit (đã chốt local-only), để đó sẽ gây hiểu nhầm.
- `Hướng dẫn Widget iOS 18` — chính là màn 09 vừa loại.
- `Đánh giá ứng dụng` — app riêng, không có App Store.
- `Mã nguồn GitHub` — có thể giữ 1 dòng link nếu bạn muốn, nhưng không cần trong app.
- Card "THÔNG TIN ỨNG DỤNG" (version/build) → gộp thành 1 dòng footer `Dayline v1.0.0 (1)`.
- Thanh "DAYLINE + Cài Đặt" trùng lặp ở đầu → chỉ dùng large title.
- Bớt "Bắt đầu ngày mới 07:30" nếu không làm tính năng đó (hiện chưa có trong plan).

### 3.6. `10_ch_n_o_n_h_th_ng` — rút thành sheet Chẩn đoán

Chỉ giữ 6 dòng: `App Group ID` (+ OK/lỗi), `Widget Extension`, `Snapshot size`, `SwiftData (số task/note)`, `Quyền thông báo`, `Số notification đang chờ`. Bỏ console giả, bỏ "kiểm tra đồng bộ / ghi log test / khôi phục cache" (chỉ giữ nút **Xuất log .txt**). Đây là công cụ debug vì bạn không có Xcode.

---

## 4. Widget — chốt từ mockup 11 & 12

| Surface | Kích thước | Nội dung | Ghi chú |
|---|---|---|---|
| `accessoryInline` | 1 dòng | `14:30 · Họp review` | cắt title ≤ 18 ký tự |
| `accessoryCircular` | 72×72 | ring + `3/7` | 1 màu, `AccessoryWidgetBackground` |
| `accessoryRectangular` | 160×72 | `TIẾP THEO` / `14:30 · Tên` / `Còn 2 việc` | 3 dòng |
| Home small | 158×158 | ring + số còn lại | chưa có trong mockup → tự dựng theo token |
| Home medium | 338×158 | 3 task kế + giờ | mockup có sẵn |
| Live Activity | Lock screen banner | tên task, `Text(timerInterval:)`, progress, 2 nút `Đã xong` / `+15 phút` | máy không có Dynamic Island |

Phải làm cả 2 bản màu: **Standard** và **iOS 18 Tinted** (mockup đã có toggle). Nút trong Live Activity = `LiveActivityIntent` (iOS 17.2+) — để P2, làm sau khi phần đếm ngược chạy.

---

## 5. Lệch giữa ảnh Stitch và DESIGN.md (chốt theo ảnh)

| Điểm | DESIGN.md | Ảnh Stitch | Chốt |
|---|---|---|---|
| Checkbox | bên trái | bên phải | **bên phải** (thuận tay, ảnh đã đẹp) |
| Giờ | cột riêng bên phải | dưới tiêu đề | **dưới tiêu đề**, kiểu `time` tabular |
| Header Today | ring 40/64pt | avatar | **ring 40pt** |
| Tab bar | 4 tab | 4 tab (có Thống kê) | **3 tab** |
| Font | SF Pro | serif (fallback của Stitch) | **SF Pro** — không copy font từ Stitch |

Font trong ảnh bị fallback sang serif: đó là lỗi render của Stitch, **không** đưa vào app. Mọi text dùng SF Pro theo token.

---

## 6. Việc tiếp theo

1. Chốt danh sách trên (nếu muốn bỏ thêm "Chẩn đoán" hoặc "Tổng kết ngày" thì nói).
2. Tôi dựng `Theme.swift` + `TaskRow` + `TodayView` + `TaskEditor` với dữ liệu mock để bạn cài lên máy xem trước.
3. Phần backend (B0 → B6) chạy theo `02-backend-domain-and-ci.md`.
