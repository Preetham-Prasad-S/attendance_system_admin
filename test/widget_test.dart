import 'package:attendance_system_admin/app/app.dart';
import 'package:attendance_system_admin/core/di/injection_container.dart';
import 'package:attendance_system_admin/features/auth/presentation/screens/login/login_screen.dart';
import 'package:attendance_system_admin/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:attendance_system_admin/features/dashboard/presentation/widgets/sidebar/dashboard_sidebar.dart';
import 'package:attendance_system_admin/features/dashboard/presentation/widgets/top_bar/dashboard_top_bar.dart';
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

  testWidgets('renders the dashboard shell', (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: DashboardScreen()));

    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.byType(DashboardSidebar), findsOneWidget);
    expect(find.byType(DashboardTopBar), findsOneWidget);
  });
}
