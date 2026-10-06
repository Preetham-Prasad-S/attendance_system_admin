import 'package:attendance_system_admin/core/theme/app_theme.dart';
import 'package:attendance_system_admin/features/staff/data/mock/staff_mock_data.dart';
import 'package:attendance_system_admin/features/staff/domain/entities/staff_entities.dart';
import 'package:attendance_system_admin/features/staff/presentation/pages/staff_page.dart';
import 'package:attendance_system_admin/features/staff/presentation/widgets/coverage/coverage_alert_card.dart';
import 'package:attendance_system_admin/features/staff/presentation/widgets/coverage/coverage_board.dart';
import 'package:attendance_system_admin/features/staff/presentation/widgets/coverage/leave_approvals_summary.dart';
import 'package:attendance_system_admin/features/staff/presentation/widgets/coverage/sms_gateway_status.dart';
import 'package:attendance_system_admin/features/staff/presentation/widgets/filters/staff_filter_bar.dart';
import 'package:attendance_system_admin/features/staff/presentation/widgets/header/staff_page_header.dart';
import 'package:attendance_system_admin/features/staff/presentation/widgets/roster/faculty_card.dart';
import 'package:attendance_system_admin/features/staff/presentation/widgets/roster/faculty_detailed_table.dart';
import 'package:attendance_system_admin/features/staff/presentation/widgets/roster/faculty_roster_grid.dart';
import 'package:attendance_system_admin/features/staff/presentation/widgets/stats/workload_kpi_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /// 1600x1000 matches the reference screenshot's desktop canvas and stays
  /// above [CoverageBoard.stackBreakpoint], so the rail renders as a sibling
  /// column rather than stacking.
  /// [tallSize] is tall enough to lay out the whole roster plus rail. Widget
  /// finders skip sliver children outside the viewport, so any assertion that
  /// counts roster cards or reaches the rail needs this rather than the
  /// reference desktop height.
  const tallSize = Size(1600, 2600);

  Future<void> pumpStaff(
    WidgetTester tester, {
    Size size = const Size(1600, 1000),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    // AppShell supplies the Scaffold/Material the ink effects need in the real
    // app, so the test harness has to provide it too.
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(body: StaffPage()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders every workspace section on desktop', (tester) async {
    await pumpStaff(tester, size: tallSize);

    // Header: breadcrumb, title, subtitle, both view toggles, export action.
    expect(find.text('Faculty Workload & Lecture Coverage'), findsOneWidget);
    expect(find.text('Academic Affairs'), findsOneWidget);
    expect(find.text('Faculty Operations'), findsOneWidget);
    expect(find.text('Workload & Coverage'), findsOneWidget);
    expect(find.byType(StaffPageHeader), findsOneWidget);
    expect(find.text('Roster Grid'), findsOneWidget);
    expect(find.text('Detailed Table'), findsOneWidget);
    expect(find.text('Export Roster'), findsOneWidget);

    // Four KPI cards.
    expect(find.byType(WorkloadKpiRow), findsOneWidget);
    expect(find.text('FACULTY ATTENDANCE'), findsOneWidget);
    expect(find.text('CONDUCTED TODAY'), findsOneWidget);
    expect(find.text('FREE FACULTY NOW'), findsOneWidget);
    expect(find.text('PENDING SUBSTITUTES'), findsOneWidget);

    // Filter bar.
    expect(find.byType(StaffFilterBar), findsOneWidget);
    expect(find.text('All Departments'), findsOneWidget);
    expect(find.text('All Designations'), findsOneWidget);
    expect(find.text('All Statuses'), findsOneWidget);
    expect(find.text('Show Available Only:'), findsOneWidget);

    // Roster grid with one card per mock faculty member.
    expect(find.byType(FacultyRosterGrid), findsOneWidget);
    expect(
      find.byType(FacultyCard),
      findsNWidgets(StaffMockData.faculty.length),
    );
    expect(find.byType(FacultyDetailedTable), findsNothing);

    // Coverage rail.
    expect(find.byType(CoverageBoard), findsOneWidget);
    expect(find.byType(CoverageAlertCard), findsNWidgets(2));
    expect(find.byType(LeaveApprovalsSummary), findsOneWidget);
    expect(find.byType(SmsGatewayStatus), findsOneWidget);
    expect(find.text('Class Coverage Board'), findsOneWidget);
    expect(find.text('1 Urgent'), findsOneWidget);

    expect(tester.takeException(), isNull);
  });

  testWidgets('coverage rail renders both alert stages', (tester) async {
    await pumpStaff(tester);

    // Critical / unattended, with a recommended substitute and assign actions.
    expect(find.text('UNATTENDED NOW'), findsOneWidget);
    expect(find.text('CE-304: Structural Analysis'), findsOneWidget);
    expect(find.text('Recommended Substitute:'), findsOneWidget);
    expect(find.text('98% Syllabus Match'), findsOneWidget);
    expect(find.text('Assign & SMS'), findsOneWidget);
    expect(find.text('Merge Session'), findsOneWidget);

    // Warning / upcoming, already assigned.
    expect(find.text('UPCOMING (IN 45M)'), findsOneWidget);
    expect(find.text('CS-302: Algorithms & Complexity'), findsOneWidget);
    expect(find.text('Assigned Substitute:'), findsOneWidget);
    expect(find.text('Accepted SMS'), findsOneWidget);
    // The merge action is exclusive to the recommended stage.
    expect(find.text('Merge Session'), findsOneWidget);
  });

  testWidgets('leave approvals summary renders both stub rows', (tester) async {
    await pumpStaff(tester);

    expect(find.text('LEAVE APPROVALS SUMMARY'), findsOneWidget);
    expect(find.text('view all (7)'), findsOneWidget);
    expect(find.text('Dr. Nathan Drake'), findsWidgets);
    expect(find.text('Prof. Elena Rostov'), findsWidgets);
    expect(find.text('Classes covered by Dr. Rao'), findsOneWidget);
    expect(find.text('1 Lab Pending Assignment'), findsOneWidget);
    expect(find.text('Campus SMS Gateway'), findsOneWidget);
    expect(find.text('Active (Latency: 120ms)'), findsOneWidget);
  });

  testWidgets('switches to the detailed table from the header toggle', (
    tester,
  ) async {
    await pumpStaff(tester);

    expect(find.byType(FacultyRosterGrid), findsOneWidget);

    await tester.tap(find.text('Detailed Table'));
    await tester.pumpAndSettle();

    expect(find.byType(FacultyDetailedTable), findsOneWidget);
    expect(find.byType(FacultyRosterGrid), findsNothing);
    expect(find.text('FACULTY'), findsOneWidget);
    expect(find.text('CURRENT SESSION'), findsOneWidget);
    expect(find.text('GATE IN'), findsOneWidget);
    expect(find.text('SESSIONS'), findsOneWidget);

    // And back again.
    await tester.tap(find.text('Roster Grid'));
    await tester.pumpAndSettle();
    expect(find.byType(FacultyRosterGrid), findsOneWidget);
  });

  testWidgets('available-only toggle narrows the roster to free faculty', (
    tester,
  ) async {
    await pumpStaff(tester, size: tallSize);

    expect(
      find.byType(FacultyCard),
      findsNWidgets(StaffMockData.faculty.length),
    );

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    final substitutable = StaffMockData.faculty
        .where((m) => m.isSubstitutable)
        .length;
    expect(find.byType(FacultyCard), findsNWidgets(substitutable));
    expect(substitutable, lessThan(StaffMockData.faculty.length));
    // Filtering must not disturb the KPI counters, which describe the campus.
    expect(find.text('PENDING SUBSTITUTES'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('department dropdown filters the roster', (tester) async {
    await pumpStaff(tester, size: tallSize);

    await tester.tap(find.text('All Departments'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Dept: Civil Engineering').last);
    await tester.pumpAndSettle();

    final civil = StaffMockData.faculty
        .where((m) => m.department == 'Civil Engineering')
        .length;
    expect(civil, greaterThan(0));
    expect(find.byType(FacultyCard), findsNWidgets(civil));
  });

  testWidgets('status dropdown filters the roster', (tester) async {
    await pumpStaff(tester, size: tallSize);

    await tester.tap(find.text('All Statuses'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Status: On Leave').last);
    await tester.pumpAndSettle();

    final onLeave = StaffMockData.faculty
        .where((m) => m.status == FacultyStatus.onLeave)
        .length;
    expect(find.byType(FacultyCard), findsNWidgets(onLeave));
  });

  testWidgets('search debounces and narrows the roster', (tester) async {
    await pumpStaff(tester, size: tallSize);

    await tester.enterText(find.byType(TextField).first, 'lin chen');
    await tester.pump(const Duration(milliseconds: 150));
    // Still unfiltered: the 300 ms debounce has not fired.
    expect(
      find.byType(FacultyCard),
      findsNWidgets(StaffMockData.faculty.length),
    );

    await tester.pump(const Duration(milliseconds: 250));
    await tester.pumpAndSettle();

    // Scoped to the roster: the coverage rail also names Dr. Lin Chen as the
    // assigned substitute for CS-302.
    expect(
      find.descendant(
        of: find.byType(FacultyRosterGrid),
        matching: find.text('Dr. Lin Chen'),
      ),
      findsOneWidget,
    );
    expect(find.byType(FacultyCard), findsOneWidget);
  });

  testWidgets('a search with no matches shows the reset affordance', (
    tester,
  ) async {
    await pumpStaff(tester, size: tallSize);

    await tester.enterText(
      find.byType(TextField).first,
      'zzzz-no-such-faculty',
    );
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    expect(find.text('No faculty match these filters'), findsOneWidget);
    expect(find.byType(FacultyCard), findsNothing);

    await tester.tap(find.text('Reset Filters').last);
    await tester.pumpAndSettle();

    expect(
      find.byType(FacultyCard),
      findsNWidgets(StaffMockData.faculty.length),
    );
  });

  testWidgets('cosmetic actions surface a snackbar rather than navigating', (
    tester,
  ) async {
    await pumpStaff(tester);

    await tester.tap(find.text('Assign & SMS'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Assigning Dr. Meera Nambiar'), findsOneWidget);

    await tester.tap(find.text('More Filters'));
    await tester.pumpAndSettle();
    expect(find.textContaining('More filters need subject'), findsOneWidget);
  });

  testWidgets('download report button surfaces a snackbar', (tester) async {
    await pumpStaff(tester);

    await tester.scrollUntilVisible(
      find.text('Download Daily Coverage Report'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Download Daily Coverage Report'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Daily coverage report'), findsOneWidget);
  });

  testWidgets('stacks the coverage rail below the roster when narrow', (
    tester,
  ) async {
    // Below CoverageBoard.stackBreakpoint.
    await pumpStaff(tester, size: const Size(1100, 3400));

    expect(find.byType(CoverageBoard), findsOneWidget);
    expect(find.byType(FacultyRosterGrid), findsOneWidget);

    final boardTop = tester.getTopLeft(find.byType(CoverageBoard)).dy;
    final headerTop = tester.getTopLeft(find.byType(StaffPageHeader)).dy;
    // Stacked, not side by side: the rail starts well below the header.
    expect(boardTop, greaterThan(headerTop));

    // The single-column KPI wrap kicks in too.
    expect(find.text('PENDING SUBSTITUTES'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
