import 'package:attendance_system_admin/app/app.dart';
import 'package:attendance_system_admin/app/shell/app_shell.dart';
import 'package:attendance_system_admin/app/shell/widgets/sidebar/app_sidebar.dart';
import 'package:attendance_system_admin/app/shell/widgets/sidebar/sidebar_nav_item.dart';
import 'package:attendance_system_admin/app/shell/widgets/top_bar/app_top_bar.dart';
import 'package:attendance_system_admin/core/di/injection_container.dart';
import 'package:attendance_system_admin/features/auth/presentation/bloc/session_cubit.dart';
import 'package:attendance_system_admin/features/auth/presentation/screens/login/login_screen.dart';
import 'package:attendance_system_admin/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:attendance_system_admin/features/institutes/presentation/bloc/institutes_bloc.dart';
import 'package:attendance_system_admin/features/institutes/presentation/bloc/institutes_event.dart';
import 'package:attendance_system_admin/features/staff/presentation/pages/staff_page.dart';
import 'package:attendance_system_admin/features/staff/presentation/widgets/coverage/coverage_board.dart';
import 'package:attendance_system_admin/features/students/presentation/pages/students_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'https://test.supabase.co',
      anonKey: 'test-anon-key',
    );
    await initDependencies();
  });

  /// The shell reads identity (for role-gated nav) and the institute
  /// registry. Both are provided by the app root, so a shell-only test has to
  /// supply them.
  Widget wrapShell() {
    final sessionCubit = serviceLocator<SessionCubit>();
    final institutesBloc = serviceLocator<InstitutesBloc>();
    institutesBloc.add(const InstitutesLoadRequested());
    addTearDown(sessionCubit.close);
    addTearDown(institutesBloc.close);

    return MultiBlocProvider(
      providers: [
        BlocProvider<SessionCubit>.value(value: sessionCubit),
        BlocProvider<InstitutesBloc>.value(value: institutesBloc),
      ],
      child: const AppShell(),
    );
  }

  testWidgets('renders the login screen when signed out', (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const CampusPulseApp());

    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('renders the app shell', (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(home: wrapShell()));

    expect(find.byType(AppShell), findsOneWidget);
    expect(find.byType(AppSidebar), findsOneWidget);
    expect(find.byType(AppTopBar), findsOneWidget);
  });

  testWidgets('hides the Students entry from the sidebar', (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(home: wrapShell()));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(SidebarNavItem, 'Students'), findsNothing);
    expect(find.byType(StudentsPage), findsNothing);
    expect(find.byType(DashboardPage), findsOneWidget);
  });

  testWidgets('navigates to the Staff page from the sidebar', (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(home: wrapShell()));
    await tester.pumpAndSettle();

    expect(find.byType(StaffPage), findsNothing);

    final staffItem = find.widgetWithText(SidebarNavItem, 'Staff/Faculty');
    await tester.tap(staffItem, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.byType(StaffPage), findsOneWidget);
    // The "Live" pill is active-state-only, so it rides along with selection.
    expect(
      find.descendant(of: staffItem, matching: find.text('Live')),
      findsOneWidget,
    );
    expect(find.text('Faculty Workload & Lecture Coverage'), findsOneWidget);
    expect(find.byType(CoverageBoard), findsOneWidget);
  });

  testWidgets('placeholder nav entries stay inert', (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(home: wrapShell()));
    await tester.pumpAndSettle();

    await tester.tap(
      find.widgetWithText(SidebarNavItem, 'Timetable'),
      warnIfMissed: false,
    );
    await tester.pumpAndSettle();

    // Still on the dashboard — no page is registered for that index yet.
    expect(find.byType(DashboardPage), findsOneWidget);
    expect(find.byType(StaffPage), findsNothing);
  });
}
