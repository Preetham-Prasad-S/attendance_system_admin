# Faculty Workload & Lecture Coverage — Implementation Plan

> **Target UI:** `ui_references/staff_screen.png`
> **References:** `ui_references/screens/DESIGN.md` (design tokens), `ui_references/screens/code.html` (Tailwind source for the sibling screens)
> **Analog precedent:** `docs/ui/student-directory/PLAN.md`
> **Status:** Phases 1–7 ✅ · **Data source:** static mock (see D1)

## 1. Goal

Build the **Staff/Faculty** sidebar screen (nav index 2): a two-column
workspace — a scrollable main column (breadcrumb → title → view-mode toggle →
4 KPI cards → filter bar → faculty roster) beside a fixed-width **Class
Coverage Board** rail (unattended-session alert, upcoming session, leave
approvals summary, SMS gateway status, report download).

Data is a static fixture; no Supabase, no new dependencies.

## 2. Locked decisions

| # | Decision | Choice |
|---|---|---|
| D1 | Data source | **Const mock objects** in `data/mock/staff_mock_data.dart`. No datasource / repository / usecase / bloc / DI registration. `public.staff` (migration `0002_core_domain.sql`) has only `name`, `email`, `department`, `staff_type` — no availability, gate-in, session, or coverage columns to map |
| D2 | Navigation | Reuse the existing `IndexedStack`. `StaffPage()` fills slot 2; `SidebarNavList` flips its Staff entry to `isEnabled` |
| D3 | Design tokens | Existing `AppColors` / `AppSpacing` / `AppRadius` / `AppTypography` (Plus Jakarta Sans), **not** the Inter + Tailwind values in `DESIGN.md` — the shipped theme already matches the PNG's indigo-on-slate palette |
| D4 | KPI cards | Reuse `KpiStatCard` from `features/dashboard/presentation/widgets/stats/kpi_stat_card.dart`. Extended additively with `borderColor`, `surfaceColor`, `progressColor`, `progressTrackColor` so the amber "Pending Substitutes" card can be tinted without forking it |
| D5 | Roster tables | Hand-built `Row` + `Expanded(flex:)` columns with `FontFeature.tabularFigures()`, matching `students_table_card.dart`. No `DataTable` (it cannot render per-cell pills without a custom builder per column) |
| D6 | Avatars | Initials `CircleAvatar` with a deterministic palette keyed off the staff id — no photo assets exist in the repo |
| D7 | Responsive | ≥1280px: rail is a fixed 400px sibling with its own scroll region. <1280px: rail becomes the last section of the page's single scroll view. Roster 2→1 columns below 760px. KPI row 4→2→1 columns at 1180px / 560px |
| D8 | Cosmetic actions | `Assign & SMS`, `Merge Session`, leave approve/reject, `view all`, `More Filters`, `Download Daily Coverage Report`, per-card "Ready to Deploy" → `ScaffoldMessenger` snackbar only |
| D9 | Export Roster | **Real** — `StaffRosterCsv` + `file_saver` (already a dependency), following `DirectoryCsv` |
| D10 | Sidebar "Live" pill | `SidebarNavItem` gained an additive, nullable `activeTrailing` slot (defaults `null`, so the other nine items are untouched). `SidebarNavList` drives it from a new `_NavEntry.showLivePill` flag |
| D11 | KPI stability | KPI counters derive from the **whole** roster, never the filtered subset, so the numbers stay a fixed campus-wide reference while the roster narrows |

## 3. Design-element → data mapping

| Reference element | Treatment | Source |
|---|---|---|
| Breadcrumb *Academic Affairs › Faculty Operations › Workload & Coverage* | Static | const in `StaffPageHeader` |
| Title + subtitle | Static | const in `StaffPageHeader` |
| View toggle **Roster Grid / Detailed Table** | **Functional** | `_viewMode` in `StaffWorkspace` state |
| **Export Roster** | **Functional** | CSV of the filtered roster → `file_saver` |
| KPI *Faculty Attendance* 94.2% (+ badge) | Derived, trend from fixture | `StaffKpis.attendanceTrendPercent` |
| KPI *Conducted Today* + progress bar + "/ scheduled • in-flight" | Derived from roster sessions | `StaffKpis.conductedRatio` |
| KPI *Free Faculty Now* + "N available for substitution" | Derived | count of `FacultyStatus.available` |
| KPI *Pending Substitutes* + amber frame/accent | Derived | count of `FacultyStatus.onLeave` |
| Filter: search | **Functional**, 300 ms debounce | matches name / id / department / designation |
| Filter: Department, Designation, Status | **Functional** | `StaffFiltersX.apply` |
| Filter: **More Filters** (dashed outline) | Cosmetic | snackbar; dashed border via `_DashedBorderPainter` |
| **Show Available Only** | **Functional** | keeps only `FacultyProfile.isSubstitutable` |
| Roster card: name, `HOD` badge, status pill | Static per profile | `FacultyProfile` |
| Roster card: designation · dept, gate-in | Static | `roleLine`, `gateIn` |
| Roster card: current session / free block | Static | `FacultySession` (indigo vs cyan block) |
| Roster card: daily load bar + "N of M Sessions Complete" | Static | `scheduleRatio`, `scheduleLoadLabel` |
| Roster card: "Ready to Deploy" | Cosmetic | snackbar |
| Roster ordering | Available → teaching → on leave, then A-Z | `StaffFiltersX.sortForRoster` |
| Rail header *Class Coverage Board* + "N Urgent" | Derived from alert severities | `AlertSeverity.critical` count |
| **UNATTENDED NOW** red card: time range, course, venue line, late notice, recommended substitute + match %, Assign & SMS / Merge Session | Static data; buttons cosmetic | `CoverageAlert(stage: recommended)` |
| **UPCOMING (IN 45M)** amber card: course, approved leave, assigned substitute + Accepted SMS | Static data | `CoverageAlert(stage: assigned)` |
| **Leave Approvals Summary** + view all (7) + approve/reject | Static rows; buttons cosmetic | `LeaveApprovalStub` |
| **Campus SMS Gateway · Active (Latency: 120ms)** | Static | const on `SmsGatewayStatus` |
| **Download Daily Coverage Report** | Cosmetic | snackbar |
| Sidebar "Live" pill | Functional | `activeTrailing` / `_NavEntry.showLivePill` |

## 4. Compliance rules (documented in code)

- **Substitutability:** `FacultyProfile.isSubstitutable` requires **both**
  `FacultyStatus.available` **and** a free block — an available member who is
  already teaching cannot cover a gap.
- **Search:** trimmed, case-insensitive, matched against name, staff id,
  department, and designation; combines with every other filter (AND).
- **KPI independence:** counters are derived from the unfiltered roster, so
  narrowing the roster never changes them (asserted in
  `staff_page_test.dart`).
- **Session arithmetic:** `remaining = ΣsessionsTotal − ΣsessionsCompleted`,
  clamped at 0; `conductedRatio` guards a zero denominator.
- **Empty roster:** KPI derivation and `sessionCompletion` both return 0 rather
  than dividing by zero; the roster shows a resettable empty state.

## 5. Phases

### Phase 1 — Nav wiring + shell ✅
- `SidebarNavItem` gains a nullable `activeTrailing` shown instead of
  `trailing` while active.
- `SidebarNavList`: Staff entry flips to `isEnabled` + `showLivePill`; adds
  `_LivePill`.
- `AppShell._pages()` slot 2 becomes `const StaffPage()`.

### Phase 2 — Entities + static data ✅
- `domain/entities/staff_entities.dart` — `StaffKpis`, `FacultyProfile`,
  `FacultySession`, `FacultyStatus`, `StaffViewMode`, `CoverageAlert` +
  `AlertSeverity` + `CoverageStage`, `LeaveApprovalStub`, `StaffFilters`, and
  `facultyInitials`.
- `data/mock/staff_mock_data.dart` — 10 faculty, 2 coverage alerts, 2 leave
  stubs, plus derived `departments` / `designations` / `substitutes` /
  `urgentAlertCount`.
- `domain/staff_filters.dart` — pure `apply` / `sortForRoster` / `roster` /
  `deriveKpis` / `sessionCompletion`, so the page `build` stays declarative and
  the rules are unit-testable without pumping a widget.

### Phase 3 — Main column: header + KPIs ✅
- `pages/staff_page.dart` — `StaffPage` wrapper + `StaffWorkspace` state owner.
- `widgets/header/staff_page_header.dart` — breadcrumb, title/subtitle, meta
  chips, `_ViewToggle` segmented control, Export Roster.
- `widgets/stats/workload_kpi_row.dart` — `LayoutBuilder` + `Wrap` of four
  `KpiStatCard`s.

### Phase 4 — Filter bar ✅
- `widgets/filters/staff_filter_bar.dart` — debounced `TextField`, three generic
  `_SelectBox<T>` dropdowns, `_DashedBorderPainter` placeholder, reset chip,
  Show Available Only `Switch`.

### Phase 5 — Roster + CSV ✅
- `widgets/roster/faculty_card.dart` — 3px status rail, name/HOD/status row,
  gate-in, tinted session block, load bar, "Ready to Deploy".
- `widgets/roster/faculty_roster_grid.dart` — responsive `Wrap` + empty state.
- `widgets/roster/faculty_detailed_table.dart` — tabular alternate view with a
  count footer.
- `presentation/csv/staff_roster_csv.dart` — 14-column export with quoting.

### Phase 6 — Coverage Board rail ✅
- `widgets/coverage/coverage_board.dart` — rail assembly; `scrollable` flag so
  the desktop layout scrolls internally while the stacked layout is carried by
  the page.
- `widgets/coverage/coverage_alert_card.dart` — severity strip, notice block,
  substitute block, action row (both stages).
- `widgets/coverage/leave_approvals_summary.dart`,
  `widgets/coverage/sms_gateway_status.dart`.
- `widgets/common/status_pill.dart` — shared pill, extracted so the rail does
  not depend on the KPI row.

### Phase 7 — Tests, analyze, docs ✅
- `test/features/staff/domain/staff_filters_test.dart` — 28 tests over the pure
  helpers, `FacultyProfile`, `StaffFilters`, and mock integrity (every coverage
  alert's substitute exists on the roster).
- `test/features/staff/presentation/csv/staff_roster_csv_test.dart` — headers,
  free-block column swap, escaping, empty roster, full-roster round trip.
- `test/features/staff/presentation/staff_page_test.dart` — 12 widget tests:
  every section, both alert stages, view toggle, each filter, debounce timing,
  empty state + reset, snackbar actions, narrow stacking.
- `test/widget_test.dart` — Staff nav + "Live" pill, and that placeholder nav
  entries stay inert.
- `flutter analyze` clean (one pre-existing warning in
  `sidebar_university_selector_test.dart`); `flutter test` 167 passing.

### Phase 8 — Data wiring (not started) ❌
Add staffing availability / gate / session columns (or join `subjects`,
`class_sections`, `timetable_periods`, `leave_requests`), then
`StaffDatasource` → `StaffRepository` → usecases → `StaffBloc`, registered in
`injection_container.dart`. The presentation layer is unchanged; only the input
list to `StaffFiltersX` changes.

## 6. Risks / notes

- **No new dependencies.** `file_saver` was already present.
- **Not wiring a bloc is a deliberate deviation** from the students/dashboard
  pattern. Mitigated by keeping every filtering rule in pure functions that a
  future bloc calls unchanged.
- **Widget finders skip sliver children outside the viewport.** Roster-count
  assertions need the `tallSize` viewport in `staff_page_test.dart`; the
  reference desktop size (1600×1000) is used for layout/structure assertions.
- **The rail scrolls independently on desktop.** At 1600×1000 the reference's
  rail content is ~1720px tall, so a single shared scroll view overflows; the
  rail gets its own region instead.
- **The stack layout must not nest scroll views.** `_mainSections()` is shared
  by both branches so the stacked variant stays one `ListView`.
- `SidebarNavItem.activeTrailing` is the only cross-feature change and is
  additive with a `null` default.
