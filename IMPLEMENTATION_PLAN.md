# IMPLEMENTATION PLAN — Dayline (fix UI + backend, thực thi tuần tự)

Mục tiêu: biến bộ UI Stitch đã lọc thành app chạy thật trên iPhone 12 Pro Max (iOS 18.6), build bằng GitHub Actions, dữ liệu SwiftData local, có widget Lock Screen.

Tài liệu nguồn:

- UI đã lọc: `design/screen-inventory.md`
- Plan UI: `.opencode/plan/01-ui-stitch-to-swiftui.md`
- Plan backend: `.opencode/plan/02-backend-domain-and-ci.md`
- Design system: `stitch_smooth_motion_plan_animation/calm_native_productivity/DESIGN.md`
- Ảnh tham chiếu: `stitch_smooth_motion_plan_animation/<folder>/screen.png`

**Nguyên tắc:** không sửa file HTML/PNG trong folder Stitch (chỉ đọc). Không regenerate màn đã có. Mỗi phase kết thúc bằng 1 bản IPA cài được + screenshot CI.

---

## 0. Bảng truy vết: 16 việc phải fix

| # | Vấn đề phát hiện | Fix ở phase |
|---|---|---|
| 1 | Avatar tròn ở Today (app cá nhân không có tài khoản) | P1 → thay bằng progress ring 40pt |
| 2 | Chữ "Hôm Nay" mờ bị lặp sau tiêu đề (artifact Stitch) | P1 |
| 3 | Tab "Thống kê" không có màn nào | P1 → còn 3 tab |
| 4 | Font serif fallback của Stitch | P1 → ép SF Pro qua token |
| 5 | Lệch DESIGN.md (checkbox phải, giờ dưới title) | P1 → chốt theo ảnh |
| 6 | Thiếu state Today trống / quá hạn | P3 |
| 7 | Card gợi ý "Thời gian hoàn hảo không trùng lịch" | P4 → bỏ |
| 8 | Nút "Huỷ"/footer Task editor bị tab bar che | P4 → `safeAreaInset` |
| 9 | Label "05 — Notes List" + avatar ở Notes | P5 |
| 10 | Thiếu state search không có kết quả | P5 |
| 11 | Label "06 — Note Editor" + toolbar ảnh/code/link | P5 → cắt toolbar |
| 12 | Settings 5 nhóm, có iCloud/đánh giá/app info/widget guide | P6 → 3 nhóm |
| 13 | Màn Diagnostics là bảng demo, không phải UI | P6 → sheet 6 dòng |
| 14 | Widget cần 6 surface + 2 bản màu (Standard/Tinted) | P7 |
| 15 | Live Activity: máy không có Dynamic Island | P8 → chỉ Lock Screen |
| 16 | Không debug được bằng Xcode (Windows) | P6 → Diagnostics + export log |

---

## 1. Thứ tự phase

```
P0  Scaffold + CI + IPA đầu tiên        (gate: App Group OK?)
P1  Theme + components + Today tĩnh      ← fix #1,2,3,4,5
P2  Data layer + mock/seed
P3  Today thật + domain                  ← fix #6
P4  Task editor + notification           ← fix #7,8
P5  Notes list + note editor             ← fix #9,10,11
P6  Settings + Diagnostics               ← fix #12,13,16
P7  Widget bridge + 6 widget             ← fix #14
P8  Live Activity                        ← fix #15
P9  i18n + polish + phát hành
```

Ước lượng: **9–12 buổi**, mỗi buổi 1.5–2h + 5–8 phút/lần CI.

---

## P0 — Scaffold, CI, IPA đầu tiên (bắt buộc làm trước)

**Mục tiêu:** cài được 1 app lên máy, có widget tĩnh, và biết chắc App Group có hoạt động với Apple ID free hay không.

Việc làm:

1. `project.yml` (XcodeGen) với 3 target: `Dayline`, `DaylineWidgets`, `DaylineTests`; bundle `com.ngia.dayline` / `com.ngia.dayline.widgets`; App Group `group.com.ngia.dayline`.
2. `App/DaylineApp.swift` — `TabView` 3 tab rỗng (Hôm nay/Ghi chú/Cài đặt) + text "Dayline".
3. `Widgets/` — 1 widget tĩnh `accessoryRectangular` hiển thị "Dayline OK".
4. `Shared/AppGroupStore.swift` — ghi `probe.json` vào App Group; nếu `nil` thì log lỗi.
5. Widget đọc `probe.json` → hiển thị "group OK" hoặc "group nil".
6. `.github/workflows/ci.yml` (build + test + screenshot) và `release.yml` (unsigned IPA).
7. Tag `v0.1.0` → tải artifact → Sideloadly → cài.
8. Mở app 1 lần, thêm widget Lock Screen, chụp màn hình.

**Nghiệm thu:**

- [ ] App cài và mở được trên iPhone 12 Pro Max / iOS 18.6
- [ ] `PlugIns/DaylineWidgets.appex` có trong IPA (CI assert)
- [ ] Widget xuất hiện trong danh sách widget
- [ ] Biết kết quả: **"group OK"** hay **"group nil"** → ghi vào `design/ui-diff.md` mục "App Group"

**Gate:** nếu `nil` → vẫn đi tiếp P1–P6 (app không phụ thuộc widget), P7 xử lý fallback; quyết định mua TK $99 hoãn tới cuối P7.

---

## P1 — Theme + components + Today tĩnh

> Trạng thái: **code xong**, chờ CI xác nhận build/screenshot.

**Fix:** #1 avatar→ring, #2 ghost title, #3 bỏ tab Thống kê, #4 ép SF Pro, #5 chốt lệch spec.

1. `Shared/Theme.swift` từ DESIGN.md:
   - Color assets (light/dark): `Bg #F7F7F5/#0E0F0E`, `Surface #FFFFFF/#1A1C1A`, `Surface2 #F0F0ED/#242724`, `TextPrimary #1A1A1A/#F2F2F2`, `TextSecondary #6B6B6B/#A0A5A1`, `Border #E6E6E2/#2E322E`, `Accent #2F6B4F/#6DBE97`, `AccentBG #E7F0EA/#1E2B24`, `Success #34A853`, `Warning #E8A33D`, `Danger #D9534F`.
   - Text styles: `dlDisplay 28/34 bold`, `dlTitle 22/28 semibold`, `dlSection 13/18 semibold + tracking 0.6 + uppercase`, `dlBody 17/22`, `dlBodyEm 17/22 semibold`, `dlMeta 13/18`, `dlTime 15/20 semibold + .monospacedDigit()`.
   - `Space` enum 4/8/12/16/24/32/48, `Radius` 10/14/18/999, shadow token duy nhất cho floating button.
2. Components: `ProgressRing` (gradient `#2F6B4F→#529975`, track 3px), `TaskRow` (checkbox phải 22pt, giờ dưới title, accent bar 3px khi đang chạy), `SectionHeader`, `PrimaryButton` (52pt), `FloatingPillButton`, `Card`, `Chip`, `InputField`, `EmptyState`.
3. `TodayView` với dữ liệu tĩnh (hardcode 7 task như ảnh): header "Hôm Nay" + **ring 40pt "3/7"** thay avatar, xoá chữ mờ lặp, 3 section collapsible, floating "+ Thêm việc".
4. `RootTabView`: **3 tab** — Hôm nay (`clock`), Ghi chú (`note.text`), Cài đặt (`gearshape`).
5. Ghi quyết định #5 vào `design/ui-diff.md`: checkbox phải, giờ dưới title, ring 40pt, 3 tab.

**Nghiệm thu:**

- [ ] Screenshot CI light/dark khớp ảnh `02_today_timeline` (trừ các mục đã cố ý bỏ)
- [ ] Không còn avatar, không còn chữ lặp, không còn tab Thống kê
- [ ] Mọi text là SF Pro, không serif
- [ ] Dynamic Type 130% không vỡ layout

---

## P2 — Data layer + mock/seed

> Trạng thái: **code xong**, chờ CI xác nhận.

1. ~~`Shared/Models`~~ → `App/Data/Models`: `TaskItem`, `Note`, `RecurrenceRule`, `Priority`, `TaskDraft`/`NoteDraft`.
   **Lệch kế hoạch:** model nằm trong target app (không phải `Shared`) để widget extension không phải link SwiftData.
2. `TaskRepository` / `NoteRepository` protocol + `SwiftData*Repository` + `Mock*Repository` (seed 7 task + 5 note).
3. `SeedData.swift` + `LaunchOptions` đọc `-uiTestSeed` / `-uiTestReset` / `-uiTestLocale`.
4. `DataStore` mở SwiftData tại App Group URL nếu có, fallback local → memory → `.failed` (không `try!`).
5. Unit test round-trip export/import JSON (`schemaVersion: 1`), repository, `RecurrenceRule`.

**Nghiệm thu:** [ ] app chạy với mock, [ ] SwiftData lưu qua lần mở thứ 2, [ ] test xanh.

---

## P3 — Today thật + domain

1. `DayAggregator` (nhóm ĐANG LÀM/SẮP TỚI/ĐÃ XONG, done/total, quá hạn) + test.
2. Nối `TodayView` vào repository thật; `@Query` hoặc fetch theo ngày.
3. **State mới:** Today trống ("Hôm nay trống" + nút thêm), task quá hạn (giờ màu `Warning`, icon `exclamationmark.circle`).
4. Swipe: xoá, tick done (kèm haptic `UIImpactFeedbackGenerator(.light)`).
5. Nút "+" mở sheet editor (dựng khung trước, P4 hoàn thiện).

**Nghiệm thu:** [ ] tick done → task chuyển sang ĐÃ XONG + ring tăng, [ ] xoá hết → empty state, [ ] task giờ đã qua hiển thị đúng.

---

## P4 — Task editor + notification

1. `TaskEditorView` theo ảnh `04`: title lớn, hàng Bắt đầu + badge giờ, chip thời lượng 15/30/45/60, Lặp lại, Nhắc trước, ghi chú, nút Lưu.
2. **Bỏ** card gợi ý "Thời gian hoàn hảo…".
3. **Fix footer bị che**: `.safeAreaInset(edge: .bottom)` cho nút Lưu; nút Huỷ vào toolbar nav.
4. `RecurrenceEngine` + `NotificationPlanner` + `NotificationScheduler` (48 request / 7 ngày, dedupe ID) + test.
5. Quyền thông báo: xin khi lưu task đầu tiên có nhắc; nếu bị từ chối → banner trong Today mở Settings.
6. Reschedule khi mở app / sau mỗi write (debounce).

**Nghiệm thu:** [ ] tạo task có nhắc → nhận thông báo đúng phút trên máy thật, [ ] sửa giờ → thông báo cũ mất, [ ] task lặp daily sinh instance kế tiếp khi tick done, [ ] không có nút nào bị che.

---

## P5 — Notes list + note editor

1. `NotesListView` theo `05`: search, section ĐÃ GHIM, TẤT CẢ, preview 2 dòng, icon pin. **Bỏ** label "05 — Notes List" + avatar.
2. Giữ menu sắp xếp? → bỏ, mặc định `updatedAt` giảm dần.
3. **State search rỗng:** "Không tìm thấy ghi chú" + nút xoá từ khoá.
4. `NoteEditorView` theo `06`: title, body, toolbar **H2 · B · I · Checklist · Bullet · Pin**; bỏ `image`, `code`, `link`.
5. Toolbar gắn `.safeAreaInset(edge: .bottom)` để không bị bàn phím che.
6. Markdown renderer tối giản (heading, bold, italic, bullet, checkbox) — thuần SwiftUI, không SPM ngoài.

**Nghiệm thu:** [ ] CRUD note, [ ] search + empty state, [ ] gõ tiếng Việt có dấu không lỗi, [ ] toolbar luôn thấy khi bàn phím mở.

---

## P6 — Settings + Diagnostics

1. `SettingsView` **3 nhóm**:
   - Thông báo: Nhắc nhở công việc (toggle), Tổng kết ngày (giờ).
   - Giao diện: Ngôn ngữ (vi/en), Chế độ giao diện (Hệ thống/Sáng/Tối).
   - Dữ liệu: Xuất JSON+Markdown (share sheet), Nhập JSON, Chẩn đoán.
2. **Bỏ:** iCloud sync, Hướng dẫn Widget iOS 18, Đánh giá ứng dụng, Mã nguồn GitHub, card THÔNG TIN ỨNG DỤNG, thanh "DAYLINE" trùng lặp. Footer chỉ còn `Dayline v1.0.0 (1)`.
3. `DiagnosticsView` (sheet): 6 dòng — App Group ID + OK/nil, Widget Extension, Snapshot size, SwiftData count, quyền thông báo, số notification đang chờ; nút **Xuất log .txt**.
4. `Diagnostics.swift`: `os.Logger` 6 category + ring buffer 500 dòng.

**Nghiệm thu:** [ ] không còn mục nào chưa implement trong Settings, [ ] Diagnostics hiển thị đúng trạng thái App Group, [ ] xuất được log và share được.

---

## P7 — Widget bridge + 6 widget

1. `WidgetBridge`: build `SharedSnapshot` → ghi atomic → `WidgetCenter.reloadAllTimelines()` debounce 500ms; gọi sau mỗi write (P2 repository) + khi foreground.
2. `SnapshotBuilder` + test cắt chuỗi (inline ≤ 18 ký tự title).
3. Widget:
   - `accessoryInline`: `14:30 · Họp review`
   - `accessoryCircular`: 72×72 ring + `3/7`
   - `accessoryRectangular`: 160×72, `TIẾP THEO` / `14:30 · Tên` / `Còn 2 việc`
   - `systemSmall` 158×158: ring + số còn lại
   - `systemMedium` 338×158: 3 task kế + giờ
4. **2 bản màu:** Standard + iOS 18 Tinted (`.widgetAccentedRenderingMode`, không phụ thuộc màu để phân biệt).
5. Deep link `dayline://today`, `dayline://task/<uuid>`.
6. **Fallback khi App Group nil:** widget hiện "Mở app để đồng bộ" (đã thiết kế), không crash, ghi log.
7. Timeline entry tại mốc bắt đầu/kết thúc task.

**Nghiệm thu:** [ ] sửa task trong app → widget đổi trong ≤ 1 phút, [ ] cả 3 widget Lock Screen hiển thị đúng, [ ] tinted mode vẫn đọc được, [ ] máy không có App Group thì thấy trạng thái fallback.
**Quyết định tại đây:** nếu App Group nil → chọn (a) chấp nhận fallback, (b) mua TK $99 và bật `sign-testflight.yml`.

---

## P8 — Live Activity

1. `DaylineAttributes` (taskID, title, endDate) + `ContentState` (progress, isOverdue).
2. Lock Screen banner: tên task, `Text(timerInterval:)`, thanh tiến độ, giờ bắt đầu/kết thúc.
3. Start khi bấm "Bắt đầu" trên task; end khi tick done; `reconcile()` lúc launch dọn activity mồ côi; tự end sau `endDate + 5'`.
4. Nút "Đã xong" / "+15 phút" bằng `LiveActivityIntent` — **P2 (làm sau nếu còn thời gian)**.
5. Không làm layout Dynamic Island cho máy này; vẫn khai báo để tương lai.

**Nghiệm thu:** [ ] đếm ngược chạy đúng, [ ] kết thúc đúng, [ ] mở lại app không còn activity cũ.

---

## P9 — i18n + phát hành

1. `Localizable.xcstrings` vi + en; chuỗi ngày/giờ theo locale.
2. App icon (1024) + icon tinted/dark cho iOS 18.
3. `release.yml` tag `v1.0.0` → IPA; kiểm tra kích thước < 20MB.
4. Chạy 3 ngày liên tục: không crash, thông báo đúng, widget đúng.
5. Cập nhật `design/ui-diff.md` + README hướng dẫn cài/refresh 7 ngày.

**Nghiệm thu:** [ ] 3 ngày ổn định, [ ] IPA cài lại được sau khi hết hạn, [ ] screenshot vi/en + light/dark đủ 8 ảnh.

---

## 2. Checklist "không được làm" (tránh scope creep từ file Stitch)

- [ ] Không dựng màn Widget Guide (folder 09)
- [ ] Không dựng màn Diagnostics full như folder 10 (chỉ sheet 6 dòng)
- [ ] Không tab Thống kê, không biểu đồ
- [ ] Không onboarding, không đăng nhập, không avatar
- [ ] Không iCloud/CloudKit, không backend, không analytics
- [ ] Không toolbar ảnh/code/link trong note editor
- [ ] Không card gợi ý AI trong task editor
- [ ] Không Dynamic Island (máy không có)
- [ ] Không dùng font/serve từ HTML Stitch — chỉ token

---

## 3. Định nghĩa "xong" của toàn bộ

1. 3 tab hoạt động, dữ liệu lưu qua lần mở sau.
2. Widget Lock Screen hiển thị task kế tiếp + tiến độ ngày (hoặc fallback rõ ràng nếu App Group nil).
3. Thông báo đúng giờ, không nhân đôi, không còn sau khi xoá task.
4. Live Activity đếm ngược đúng trên Lock Screen.
5. Không màn nào còn label/số thứ tự của Stitch, không font serif, không phần tử chưa implement.
6. IPA build hoàn toàn trên GitHub Actions, cài bằng Sideloadly, không cần Mac.
