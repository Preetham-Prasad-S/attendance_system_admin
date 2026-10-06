# Student Directory & Compliance — Implementation Plan

> **Target UI:** `ui_references/screens/screen.png`
> **References:** `ui_references/screens/code.html` (Tailwind source), `ui_references/screens/DESIGN.md` (tokens), `ui_references/screens/image.png` (current dashboard = baseline)
> **Status:** Phase 1 ✅ · Phase 2 ✅ · Phase 3 ✅ · Phase 4 ✅ · Phase 5 ✅ · **Decisions locked:** 2026-10-01

## 1. Goal

Build the **Students** sidebar screen: a paginated, filterable student roster with
attendance-compliance analytics and a per-student detail panel — wired live to
Supabase (`students`, `attendance_records`), matching the reference design as
closely as the existing schema allows.

## 2. Locked decisions

| # | Decision | Choice |
|---|---|---|
| D1 | Elements whose data doesn't exist (RFID, class/sem, batch, hosteller filters, parent contact, per-course deficit) | **Omit + placeholders** — render the sections disabled/empty-state so layout still matches the design; no schema changes |
| D2 | Navigation (no routing exists today) | **Extract app shell** — `lib/app/shell/` hosting sidebar + topbar + `IndexedStack` pages; Dashboard becomes one page |
| D3 | Attendance history depth (seed has 7 days; UI needs 30-day log) | **Extend seed to 45 days** via new migration `0005` |
| D4 | Header actions (Add / Bulk Import / Export) | **Export CSV + Add New Student fully built**; Bulk Import stays a disabled stub |

## 3. Design-element → data mapping

| Screen element | Treatment | Source |
|---|---|---|
| KPI: Total Enrolled (+N this term) | Real | `students` count; `created_at ≥ now−90d` |
| KPI: Compliant (>75%) | Real | 30-day attendance window aggregate |
| KPI: Defaulters (<75%) / Critical (<65%) | Real | same aggregate |
| Filter: search, Department, Status | Real | server-side PostgREST filters |
| Filter: Batch, Class/Sem dropdowns | Placeholder | rendered disabled, value "All" |
| Quick chip: All Students, Critical Defaulters (126) | Real | critical-id set from KPI pass → `.in('id', …)` |
| Quick chips: Hostellers, Day Scholars, Pending Medical Leave | Placeholder | disabled, no counts |
| Table: Student, Department, Overall %, Sessions, Status | Real | students page + window aggregates |
| Table: Class/Sem line under dept | Placeholder | "Sem — • Sec —" |
| Table: RFID line | Placeholder | "RFID: —" |
| Table: last-seen telemetry (time + method) | Real substitute | `attendance_records.created_at` + `method` of latest record |
| Avatars | Substitute | initials `CircleAvatar`, deterministic color (no photos in schema) |
| Detail: 30-Day Attendance Log | Real | `fetchAttendanceLog(studentId, 30)`; missing days → gray "OFF" |
| Detail: Overall summary stats | Real | window aggregate for selected student |
| Detail: Course Attendance Deficit | Placeholder | empty-state: "requires Subjects & Timetable module" |
| Detail: Parent & Emergency Contact + Dispatch button | Placeholder | empty-state + disabled button |
| Actions: Export Directory | Real | CSV download of current filtered set (`file_saver`) |
| Actions: Add New Student | Real | dialog → `students` insert; unique-violation surfaced |
| Actions: Bulk Import CSV/Excel | Stub | disabled button |

## 4. Compliance rules (documented in code)

- **Window:** last 30 days (matches the 30-day log).
- **Percentage:** `pct = (present + late) / (records − on_leave) × 100`
  (late counts as attended; excused leave excluded from the denominator;
  zero denominator → "No data" gray tier).
- **Tier labels (progress bar):** ≥90 Excellent · ≥80 Good · ≥75 Compliant ·
  ≥65 Borderline · <65 Critical.
- **Status chip:** ≥75 → "Regular" (green) · ≥65 → "Defaulter" (amber) · <65 → "Critical" (red).

## 5. Phases

### Phase 1 — App shell + navigation
- Create `lib/app/shell/app_shell.dart`: `StatefulWidget` →
  `Row[DashboardSidebar | Column[DashboardTopBar, IndexedStack[DashboardPage, StudentsPage]]]`;
  indices ≥ 2 remain inert (current behavior).
- **Move** `features/dashboard/presentation/widgets/{sidebar/, top_bar/}` and
  `common/app_footer.dart` → `lib/app/shell/widgets/` (chrome is app-level).
- `DashboardScreen` → `features/dashboard/presentation/pages/dashboard_page.dart`
  (keeps only `BlocProvider + DashboardContent`).
- `SidebarNavList` gains `selectedIndex` + `onSelect(int)`; Dashboard = 0,
  Students = 1 wired with `onTap` + `isActive`.
- `app.dart` `_SessionGate` renders `AppShell`.
- Tests: `widget_test.dart` asserts shell renders; new test taps "Students"
  and expects the students page placeholder.

### Phase 2 — Seed migration `0005`
- `supabase/migrations/…_0005_student_directory_seed.sql`:
  - re-seed `attendance_records` for the last **45 days** (same deterministic
    md5 logic as `0004`);
  - stagger `students.created_at` over 18 months (~15% within last 90 days)
    so "+N this term" is meaningful.
- Apply local + remote; verify row counts.

### Phase 3 — Students data layer (mirrors dashboard clean arch)
```
lib/features/students/
├── domain/
│   ├── entities/students_entities.dart    # Student, AttendanceSummary, ComplianceTier,
│   │                                      # DirectoryKpis, DirectoryFilters, DirectoryPage,
│   │                                      # AttendanceLogDay, AddStudentParams
│   ├── repositories/students_repository.dart
│   └── usecases/  get_directory_kpis · get_students_page
│                  get_student_attendance_log · add_student
├── data/
│   ├── datasources/students_datasource(.dart/_impl.dart)
│   └── repositories/students_repository_impl.dart
└── presentation/bloc/students_{bloc,event,state}.dart
```
**Queries (PostgREST, org handled by RLS):**
1. `fetchDirectoryKpis()` — active-student count; `created_at ≥ now−90d` count;
   30-day `(student_id, status)` fetch → grouped client-side (same pattern as
   `dashboard_datasource_impl`).
2. `fetchStudentsPage(filters)` — `select('*', count: exact)` +
   `.or(ilike name/student_no/email)` + `eq department/status` +
   `.order(name).range(offset, offset+size−1)`; then window records for page
   ids → summaries. Critical-defaulter quick filter adds `.in('id', criticalIds)`.
3. `fetchAttendanceLog(studentId, 30)` — window records → 30 slots ending today.
4. `addStudent(params)` — resolve org from `profiles` (uid) → insert → map
   unique violation `23505` → "Roll number already exists".

**Bloc events:** `LoadStudentsRequested`, `SearchChanged` (300 ms debounce in
widget), `DepartmentChanged`, `StatusChanged`, `QuickFilterChanged`,
`PageChanged`, `PageSizeChanged`, `StudentSelected`, `SelectionCleared`,
`AddStudentRequested`.

### Phase 4 — UI widgets
```
students/presentation/
├── pages/students_page.dart                # BlocProvider + layout
└── widgets/
    ├── header/students_page_header.dart    # breadcrumb, title, date + "Academic
    │                                       # Sessions Active" chip, Export / Bulk (disabled) / + Add
    ├── stats/directory_kpi_row.dart        # 4× existing KpiStatCard
    ├── filters/directory_filter_bar.dart   # search, dropdowns, quick-filter chips
    ├── table/students_table_card.dart      # header/rows + pagination footer
    ├── detail/student_detail_panel.dart    # overlay panel, w = min(440, 80vw),
    │                                       #   height = content, capped by viewport
    └── students_add_dialog.dart            # Add New Student form
```
- Detail panel overlays the table's right edge (Stack), matching the
  reference where status chips are clipped beneath the panel. The `Stack`
  sits outside the page `ListView`, so the panel is scroll-persistent: it
  starts level with the table card, then pins to the top of the page body
  (`AppSpacing.xl`) once the page scrolls past it — the header's
  Export/Add actions are therefore never covered. The panel shrink-wraps
  its content and only scrolls internally when it hits its height cap.
- 30-day grid: 6×5 day-of-month chips — present green / late amber /
  absent red / on-leave blue / no-record gray "OFF"; legend + summary line.
- Table footer: "Showing X–Y of N students | Rows per page: 25 | ‹ 1 2 3 … ›"
  from real `count`.
- Selected row: checkbox + `primaryMuted` highlight + "Selected" badge.
- Export: fetch all rows matching current filters → CSV columns
  (Roll No, Name, Email, Dept, Status, Sessions, Present %, Tier) → download.
- New dependency: **`file_saver`** (web Blob download); fallback =
  copy-to-clipboard.
- Responsive: KPI row wraps, table scrolls horizontally, panel width clamps
  (desktop-first, DESIGN.md ≥1280 breakpoint).

### Phase 5 — Tests, docs, verification
- Repo impl tests (KPIs / page / log / add + failure paths), bloc tests
  (load, filters, paging, selection, add success/fail), widget tests
  (directory content at 1600×1000, sidebar navigation).
- `flutter analyze` · `flutter test` · `flutter run -d chrome` → manual E2E login.
- Docs: this file; `FUTURE_FEATURES.md` Part 7 entry (done vs placeholder);
  `docs/backend/README.md` "9 unbuilt sidebar screens" → 8; `PLAN.md` scope line.

## 6. Commit plan (on `main`; push only on request)

1. `feat(shell): extract app shell with sidebar navigation`
2. `feat(db): reseed attendance history to 45 days`
3. `feat(students): add directory data layer and bloc`
4. `feat(students): add directory page with kpis, filters, table, and detail panel`

## 7. Risks / notes

- `file_saver` is the only new dependency.
- Client-side 30-day grouping is fine at demo scale (≤ ~1,500 rows);
  noted in code as a future RPC candidate for 4,850-student scale.
- Moving sidebar/topbar touches ~10 imports + 2 tests — done first so later
  phases build on stable chrome.
- DB is disposable (docs/backend/DECISIONS.md) — re-seeding via `0005` is safe.
