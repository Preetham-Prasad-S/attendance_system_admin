import 'package:attendance_system_admin/core/usecase.dart';
import 'package:attendance_system_admin/features/dashboard/domain/entities/dashboard_entities.dart';
import 'package:attendance_system_admin/features/dashboard/domain/usecases/get_attendance_trend_usecase.dart';
import 'package:attendance_system_admin/features/dashboard/domain/usecases/get_kpis_usecase.dart';
import 'package:attendance_system_admin/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:attendance_system_admin/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:attendance_system_admin/features/dashboard/presentation/widgets/charts/attendance_trend_card.dart';
import 'package:attendance_system_admin/features/dashboard/presentation/widgets/dashboard_content.dart';
import 'package:attendance_system_admin/features/dashboard/presentation/widgets/stats/kpi_stats_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockGetKpisUsecase extends Mock implements GetKpisUsecase {}

class MockGetAttendanceTrendUsecase extends Mock
    implements GetAttendanceTrendUsecase {}

class FakeNoParams extends Fake implements NoParams {}

class FakeTrendParams extends Fake implements GetAttendanceTrendUsecaseParams {}

void main() {
  late MockGetKpisUsecase mockGetKpisUsecase;
  late MockGetAttendanceTrendUsecase mockGetAttendanceTrendUsecase;

  final tKpiStats = KpiStats(
    totalStudents: 50,
    totalStaff: 8,
    departmentCount: 5,
    presentToday: 43,
    absentToday: 3,
    lateToday: 2,
    onLeaveToday: 2,
    recordsToday: 50,
  );

  final tTrend = [
    DailyAttendancePoint(date: DateTime(2026, 9, 30), total: 50, present: 42),
    DailyAttendancePoint(date: DateTime(2026, 10, 1), total: 50, present: 43),
  ];

  setUpAll(() {
    registerFallbackValue(FakeNoParams());
    registerFallbackValue(FakeTrendParams());
  });

  setUp(() {
    mockGetKpisUsecase = MockGetKpisUsecase();
    mockGetAttendanceTrendUsecase = MockGetAttendanceTrendUsecase();

    when(
      () => mockGetKpisUsecase.call(any()),
    ).thenAnswer((_) async => Right(tKpiStats));
    when(
      () => mockGetAttendanceTrendUsecase.call(any()),
    ).thenAnswer((_) async => Right(tTrend));
  });

  testWidgets('renders KPI row and trend card once data is loaded', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (_) => DashboardBloc(
            getKpisUsecase: mockGetKpisUsecase,
            getAttendanceTrendUsecase: mockGetAttendanceTrendUsecase,
          )..add(LoadDashboardRequested()),
          child: const DashboardContent(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(KpiStatsRow), findsOneWidget);
    expect(find.byType(AttendanceTrendCard), findsOneWidget);
    expect(find.text('50'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
