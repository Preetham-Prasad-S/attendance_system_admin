import 'dart:convert';
import 'dart:typed_data';

import 'package:attendance_system_admin/app/shell/widgets/common/app_footer.dart';
import 'package:attendance_system_admin/core/theme/app_colors.dart';
import 'package:attendance_system_admin/core/theme/app_spacing.dart';
import 'package:attendance_system_admin/features/staff/data/mock/staff_mock_data.dart';
import 'package:attendance_system_admin/features/staff/domain/entities/staff_entities.dart';
import 'package:attendance_system_admin/features/staff/domain/staff_filters.dart';
import 'package:attendance_system_admin/features/staff/presentation/csv/staff_roster_csv.dart';
import 'package:attendance_system_admin/features/staff/presentation/widgets/coverage/coverage_board.dart';
import 'package:attendance_system_admin/features/staff/presentation/widgets/filters/staff_filter_bar.dart';
import 'package:attendance_system_admin/features/staff/presentation/widgets/header/staff_page_header.dart';
import 'package:attendance_system_admin/features/staff/presentation/widgets/roster/faculty_detailed_table.dart';
import 'package:attendance_system_admin/features/staff/presentation/widgets/roster/faculty_roster_grid.dart';
import 'package:attendance_system_admin/features/staff/presentation/widgets/stats/workload_kpi_row.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';

/// Faculty Workload & Lecture Coverage — the Staff/Faculty screen.
///
/// Data comes from [StaffMockData]; there is no bloc because `public.staff`
/// has no workload, availability, or coverage columns yet (see migration
/// `0002_core_domain.sql`). Filter and view state therefore lives in
/// [StaffWorkspace]'s `State`, and the filtering rules are the pure functions
/// in `StaffFiltersX` so they can be lifted into a bloc unchanged later.
class StaffPage extends StatelessWidget {
  const StaffPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const StaffWorkspace();
  }
}

/// Public so widget tests can drive it without a locator registration.
class StaffWorkspace extends StatefulWidget {
  const StaffWorkspace({super.key});

  @override
  State<StaffWorkspace> createState() => _StaffWorkspaceState();
}

class _StaffWorkspaceState extends State<StaffWorkspace> {
  StaffFilters _filters = StaffFilters.unfiltered;
  StaffViewMode _viewMode = StaffViewMode.rosterGrid;
  bool _isExporting = false;

  List<FacultyProfile> get _faculty => StaffMockData.faculty;

  /// Counts always describe the whole campus, not the current filter, so the
  /// KPI row stays a stable reference point while the roster narrows.
  StaffKpis get _kpis => StaffFiltersX.deriveKpis(StaffMockData.kpis, _faculty);

  List<FacultyProfile> get _visibleFaculty =>
      StaffFiltersX.roster(_faculty, _filters);

  void _setFilters(StaffFilters filters) => setState(() => _filters = filters);

  void _resetFilters() => setState(() => _filters = StaffFilters.unfiltered);

  void _notify(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.textPrimary,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  Future<void> _exportRoster() async {
    final rows = _visibleFaculty;
    if (rows.isEmpty) {
      _notify('No faculty match the current filters — nothing to export.');
      return;
    }
    setState(() => _isExporting = true);
    try {
      final csv = StaffRosterCsv.build(rows);
      final name = 'staff_roster_${rows.length}_faculty';
      await FileSaver.instance.saveFile(
        name: name,
        bytes: Uint8List.fromList(utf8.encode(csv)),
        fileExtension: 'csv',
        mimeType: MimeType.csv,
      );
      _notify('Exported $name (${rows.length} faculty).');
    } catch (_) {
      _notify('Export failed — check browser download permissions.');
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  /// The main column's sections, shared by both layouts so the stacked variant
  /// does not have to nest one scroll view inside another.
  List<Widget> _mainSections() {
    void deploy(FacultyProfile m) =>
        _notify('Deploying ${m.name} — no substitution flow yet.');

    return [
      StaffPageHeader(
        kpis: _kpis,
        viewMode: _viewMode,
        isExporting: _isExporting,
        onViewModeChanged: (mode) => setState(() => _viewMode = mode),
        onExport: _exportRoster,
      ),
      const SizedBox(height: AppSpacing.xl),
      WorkloadKpiRow(kpis: _kpis),
      const SizedBox(height: AppSpacing.xl),
      StaffFilterBar(
        filters: _filters,
        departments: StaffMockData.departments,
        designations: StaffMockData.designations,
        onSearch: (q) => _setFilters(_filters.copyWith(searchQuery: q)),
        onDepartment: (v) => _setFilters(
          _filters.copyWith(department: v, clearDepartment: v == null),
        ),
        onDesignation: (v) => _setFilters(
          _filters.copyWith(designation: v, clearDesignation: v == null),
        ),
        onStatus: (v) =>
            _setFilters(_filters.copyWith(status: v, clearStatus: v == null)),
        onAvailableOnly: (v) =>
            _setFilters(_filters.copyWith(availableOnly: v)),
        onMoreFilters: () =>
            _notify('More filters need subject & timetable data.'),
        onReset: _resetFilters,
      ),
      const SizedBox(height: AppSpacing.xl),
      if (_viewMode == StaffViewMode.rosterGrid)
        FacultyRosterGrid(
          faculty: _visibleFaculty,
          onDeploy: deploy,
          onReset: _filters.isActive ? _resetFilters : null,
        )
      else
        FacultyDetailedTable(
          faculty: _visibleFaculty,
          onDeploy: deploy,
          onReset: _filters.isActive ? _resetFilters : null,
        ),
      const SizedBox(height: AppSpacing.xl),
      const AppFooter(),
    ];
  }

  Widget _buildRail({required bool scrollable}) {
    return CoverageBoard(
      alerts: StaffMockData.coverageAlerts,
      leaveApprovals: StaffMockData.leaveApprovals,
      totalLeaveApprovals: StaffMockData.totalLeaveApprovals,
      onAssign: (alert) => _notify(
        'Assigning ${alert.substituteName} to '
        '${alert.courseCode} — not wired to a roster yet.',
      ),
      onMerge: (alert) =>
          _notify('Merging ${alert.courseCode} with the next section.'),
      onApproveLeave: (r) => _notify('Approved ${r.facultyName}.'),
      onRejectLeave: (r) => _notify('Rejected ${r.facultyName}.'),
      onViewAllLeave: () => _notify('Leave Approvals screen is not built yet.'),
      onDownloadReport: () =>
          _notify('Daily coverage report generation is not wired yet.'),
      scrollable: scrollable,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Below the breakpoint the rail cannot fit beside the roster, so it
        // joins the page's own scroll view as the last section.
        final stack = constraints.maxWidth < CoverageBoard.stackBreakpoint;

        if (stack) {
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            children: [
              ..._mainSections(),
              const SizedBox(height: AppSpacing.xl),
              _buildRail(scrollable: false),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                children: _mainSections(),
              ),
            ),
            const SizedBox(width: AppSpacing.xl),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: SizedBox(
                width: CoverageBoard.railWidth,
                child: _buildRail(scrollable: true),
              ),
            ),
          ],
        );
      },
    );
  }
}
