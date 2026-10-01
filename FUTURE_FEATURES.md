# Future Features

Features that are implemented as files/components but **not shown in the UI yet**, plus planned parts from the dashboard roadmap. Re-enable by adding the widget back into the parent layout noted below.

---

## Hidden / pending UI features

### 1. IoT Terminals Status Chip
- **File:** `lib/features/dashboard/presentation/widgets/top_bar/top_bar_iot_status_chip.dart`
- **Widget:** `TopBarIotStatusChip`
- **Description:** Top bar pill showing "24/26 IoT Terminals Live" with a router icon and green background. Represents live biometric terminal connectivity.
- **Status:** Hidden — removed from `DashboardTopBar` row.
- **To re-enable:** Add `const TopBarIotStatusChip()` back into the Row in `lib/features/dashboard/presentation/widgets/top_bar/dashboard_top_bar.dart` (between `TopBarTermSelector` and `Spacer`).
- **Depends on:** IoT gateway data (see "Data wiring" below) to compute live terminal count.

### 2. Sidebar Storage & System Health Card
- **File:** `lib/features/dashboard/presentation/widgets/sidebar/sidebar_storage_card.dart`
- **Widget:** `SidebarStorageCard`
- **Description:** Sidebar bottom card with storage sync status ("99.4% Sync"), indigo progress bar, and system health indicator ("Optimal" with green dot).
- **Status:** Hidden — removed from `DashboardSidebar` column.
- **To re-enable:** Add `const SidebarStorageCard()` as the last child of the Column in `lib/features/dashboard/presentation/widgets/sidebar/dashboard_sidebar.dart`.
- **Depends on:** Storage/health telemetry from the backend or device hub.

### 3. Live IoT Stream Card
- **File:** `lib/features/dashboard/presentation/widgets/analytics/live_iot_stream_card.dart`
- **Widget:** `LiveIoTStreamCard`
- **Description:** Analytics-row card streaming 4 live attendance events (avatar, name, status chip, location subtitle, time meta) with an "INGESTING" pill and a gateway log link.
- **Status:** Hidden — removed from the analytics Row in `dashboard_content.dart` (right rail removed).
- **To re-enable (both #3 and #4 together):** In `lib/features/dashboard/presentation/widgets/dashboard_content.dart`, restore both analytics imports and add the third `Expanded` back to the analytics Row: `Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [LiveIoTStreamCard(), SizedBox(height: AppSpacing.xl), IoTTelemetryCard()]))` as the last child — the Row returns to three equal columns.
- **Depends on:** Live attendance event stream from the IoT gateway (Part 6 data wiring).

### 4. IoT Telemetry Card
- **File:** `lib/features/dashboard/presentation/widgets/analytics/iot_telemetry_card.dart`
- **Widget:** `IoTTelemetryCard`
- **Description:** Compact card with gradient accent bar showing mesh network latency, sync status, and refresh cadence.
- **Status:** Hidden — removed with the analytics right rail (see #3).
- **To re-enable:** Same as #3 (both cards re-enter together as the rail Column).
- **Depends on:** Device telemetry feed (Part 6 data wiring).

---

## Planned dashboard parts (from UI reference `ui_references/screens/image.png`)

### Part 2 — Page header + KPI stat cards ✅ DONE
- **Location:** `lib/features/dashboard/presentation/widgets/header/` and `lib/features/dashboard/presentation/widgets/stats/`
- **Description:** Implemented — `DashboardHeader`, `HeaderActionButtons`, `KpiStatsRow`, `KpiStatCard` with hardcoded values (wired to backend in Part 6).

### Part 3 — Attendance trend chart + Urgent alerts ✅ DONE
- **Location:** `lib/features/dashboard/presentation/widgets/charts/` and `lib/features/dashboard/presentation/widgets/alerts/`
- **Description:** Implemented — `AttendanceTrendCard` (fl_chart line chart, dashed 75% threshold, legend, period toggle, static tooltip, footer stats), `TrendPeriodToggle`, `UrgentAlertsCard` (3 actionable alerts with action buttons). Data hardcoded until Part 6.

### Part 4 — Analytics row (Department, Presence split, IoT stream, Telemetry) ✅ DONE
- **Location:** `lib/features/dashboard/presentation/widgets/analytics/`
- **Description:** Implemented — `DepartmentBreakdownCard` (6 department progress bars, filter/roster links), `PresenceSplitCard` (fl_chart donut with center total + 4-item legend), `LiveIoTStreamCard` + `IoTTelemetryCard` (now hidden — see hidden features #3/#4). Dashboard row shows Department + Presence as two equal columns. Data hardcoded until Part 6.

### Part 5 — Recent roll-call table + footer ✅ DONE
- **Location:** `lib/features/dashboard/presentation/widgets/table/` and `lib/features/dashboard/presentation/widgets/common/`
- **Description:** Implemented — `RollCallTableCard` (7-column live sessions table with attendance chips, turn-out ratios, Export Daily CSV button, "Showing 4 of 64 Classes" counter) and `AppFooter` (version/certification left, session ID right), replacing the `SectionPlaceholder` in `dashboard_content.dart`. Data hardcoded until Part 6.

### Part 6 — Data wiring (replace hardcoded values) — MOSTLY DONE
- **Done (live against Supabase):** KPI stats row (`KpiStatsRow` ← `GetKpisUsecase`), attendance trend chart (`AttendanceTrendCard` ← `GetAttendanceTrendUsecase`, Weekly/Monthly/Semester), presence split donut (`PresenceSplitCard` ← `KpiStats`), department breakdown bars (`DepartmentBreakdownCard` ← `GetDepartmentStatsUsecase`, per-department today's present %), urgent alerts (`UrgentAlertsCard` ← `GetAlertsUsecase`: 7-day compliance breaches + today's absence watch, dynamic badge/empty state). Stack: `dashboard_entities.dart`, `DashboardRepository(+Impl)`, `DashboardDatasource(+Impl)`, `DashboardBloc`, DI registrations, header date. Demo data seeded via migration `0004`.
- **Remaining (blocked on deferred tables):** `RollCallTableCard` (needs `subjects`/`class_sections`/`timetable_periods` + sessions), IoT widgets (`devices`), sidebar leave badge `12` (`leave_requests`), roster/terminal alert types (needs `timetable`/`devices`).
- **Planned location:**
  - Entities: `lib/features/dashboard/domain/entities/`
  - Repository interfaces: `lib/features/dashboard/domain/repositories/`
  - Use cases: `lib/features/dashboard/domain/usecases/`
  - BLoC/Cubit: `lib/features/dashboard/presentation/bloc/`
  - Supabase data sources: `lib/features/dashboard/data/datasources/`
  - Repository implementations: `lib/features/dashboard/data/repositories/`
  - Models: `lib/features/dashboard/data/models/`
  - DI registrations: `lib/core/di/`
- **Description:** Connect all dashboard widgets to real Supabase data (attendance records, students, staff, devices, alerts) via use cases and BLoC, replacing hardcoded UI values.
