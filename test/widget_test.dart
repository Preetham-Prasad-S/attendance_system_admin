import 'package:attendance_system_admin/app/app.dart';
import 'package:attendance_system_admin/app/shell/app_shell.dart';
import 'package:attendance_system_admin/app/shell/widgets/sidebar/app_sidebar.dart';
import 'package:attendance_system_admin/app/shell/widgets/sidebar/sidebar_nav_item.dart';
import 'package:attendance_system_admin/app/shell/widgets/top_bar/app_top_bar.dart';
import 'package:attendance_system_admin/core/di/injection_container.dart';
import 'package:attendance_system_admin/features/auth/presentation/screens/login/login_screen.dart';
import 'package:attendance_system_admin/features/students/presentation/pages/students_page.dart';
import 'package:flutter/material.dart';
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

    await tester.pumpWidget(const MaterialApp(home: AppShell()));

    expect(find.byType(AppShell), findsOneWidget);
    expect(find.byType(AppSidebar), findsOneWidget);
    expect(find.byType(AppTopBar), findsOneWidget);
  });

  testWidgets('navigates to the Students page from the sidebar', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: AppShell()));
    await tester.pumpAndSettle();

    expect(find.byType(StudentsPage), findsNothing);

    await tester.tap(
      find.widgetWithText(SidebarNavItem, 'Students'),
      warnIfMissed: false,
    );
    await tester.pumpAndSettle();

    expect(find.byType(StudentsPage), findsOneWidget);
    expect(find.text('Students — coming soon'), findsOneWidget);
  });
}
