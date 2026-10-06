import '../../../../helpers/institutes_fixture.dart';
import 'package:attendance_system_admin/core/failure.dart';
import 'package:attendance_system_admin/core/usecase.dart';
import 'package:attendance_system_admin/features/dashboard/domain/entities/dashboard_entities.dart';
import 'package:attendance_system_admin/features/dashboard/domain/usecases/get_alerts_usecase.dart';
import 'package:attendance_system_admin/features/dashboard/domain/usecases/get_attendance_trend_usecase.dart';
import 'package:attendance_system_admin/features/dashboard/domain/usecases/get_department_stats_usecase.dart';
import 'package:attendance_system_admin/features/dashboard/domain/usecases/get_kpis_usecase.dart';
import 'package:attendance_system_admin/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:attendance_system_admin/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:attendance_system_admin/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockGetKpisUsecase extends Mock implements GetKpisUsecase {}

class MockGetAttendanceTrendUsecase extends Mock
    implements GetAttendanceTrendUsecase {}

class MockGetDepartmentStatsUsecase extends Mock
    implements GetDepartmentStatsUsecase {}

class MockGetAlertsUsecase extends Mock implements GetAlertsUsecase {}

class FakeNoParams extends Fake implements NoParams {}

class FakeTrendParams extends Fake implements GetAttendanceTrendUsecaseParams {}

void main() {
  late DashboardBloc dashboardBloc;
  late MockGetKpisUsecase mockGetKpisUsecase;
  late MockGetAttendanceTrendUsecase mockGetAttendanceTrendUsecase;
  late MockGetDepartmentStatsUsecase mockGetDepartmentStatsUsecase;
  late MockGetAlertsUsecase mockGetAlertsUsecase;

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

  final tWeeklyTrend = [
    DailyAttendancePoint(date: DateTime(2026, 9, 30), total: 50, present: 42),
    DailyAttendancePoint(date: DateTime(2026, 10, 1), total: 50, present: 43),
  ];

  final tMonthlyTrend = [
    DailyAttendancePoint(date: DateTime(2026, 9, 2), total: 50, present: 40),
    DailyAttendancePoint(date: DateTime(2026, 9, 30), total: 50, present: 42),
    DailyAttendancePoint(date: DateTime(2026, 10, 1), total: 50, present: 43),
  ];

  final tDepartments = [
    DepartmentStat(name: 'Computer Science', recordsToday: 50, presentToday: 44),
    DepartmentStat(name: 'Electronics', recordsToday: 50, presentToday: 42),
  ];

  final tAlerts = [
    DashboardAlert(
      type: 'THRESHOLD BREACH',
      title: '3 Students below 75% in Computer Science',
      description: 'Attendance below the institutional minimum.',
      time: 'Last 7 days',
      actionLabel: 'Review & Notify Parents',
      actionStyle: AlertActionStyle.filled,
    ),
  ];

  setUpAll(() {
    registerFallbackValue(FakeNoParams());
    registerFallbackValue(FakeTrendParams());
  });

  setUp(() {
    mockGetKpisUsecase = MockGetKpisUsecase();
    mockGetAttendanceTrendUsecase = MockGetAttendanceTrendUsecase();
    mockGetDepartmentStatsUsecase = MockGetDepartmentStatsUsecase();
    mockGetAlertsUsecase = MockGetAlertsUsecase();

    when(
      () => mockGetDepartmentStatsUsecase.call(any()),
    ).thenAnswer((_) async => Right(tDepartments));
    when(
      () => mockGetAlertsUsecase.call(any()),
    ).thenAnswer((_) async => Right(tAlerts));

    dashboardBloc = DashboardBloc(
      getKpisUsecase: mockGetKpisUsecase,
      getAttendanceTrendUsecase: mockGetAttendanceTrendUsecase,
      getDepartmentStatsUsecase: mockGetDepartmentStatsUsecase,
      getAlertsUsecase: mockGetAlertsUsecase,
      instituteContext: buildInstituteContext(),
    );
  });

  tearDown(() {
    dashboardBloc.close();
  });

  group('DashboardBloc - Load', () {
    test('initial state should be DashboardInitial', () {
      expect(dashboardBloc.state, isA<DashboardInitial>());
    });

    test(
      'should emit [DashboardLoading, DashboardLoaded] when load is successful',
      () async {
        // arrange
        when(
          () => mockGetKpisUsecase.call(any()),
        ).thenAnswer((_) async => Right(tKpiStats));
        when(
          () => mockGetAttendanceTrendUsecase.call(any()),
        ).thenAnswer((_) async => Right(tWeeklyTrend));

        // assert later
        final expected = [
          isA<DashboardLoading>(),
          isA<DashboardLoaded>()
              .having((state) => state.kpis, 'kpis', tKpiStats)
              .having((state) => state.trend, 'trend', tWeeklyTrend)
              .having((state) => state.period, 'period', TrendPeriod.weekly)
              .having(
                (state) => state.departments,
                'departments',
                tDepartments,
              )
              .having((state) => state.alerts, 'alerts', tAlerts),
        ];
        expectLater(dashboardBloc.stream, emitsInOrder(expected));

        // act
        dashboardBloc.add(LoadDashboardRequested());
      },
    );

    test(
      'should emit [DashboardLoading, DashboardFailureState] when kpis fail',
      () async {
        // arrange
        when(
          () => mockGetKpisUsecase.call(any()),
        ).thenAnswer((_) async => Left(ServerFailure(message: 'kpis failed')));
        when(
          () => mockGetAttendanceTrendUsecase.call(any()),
        ).thenAnswer((_) async => Right(tWeeklyTrend));

        // assert later
        final expected = [
          isA<DashboardLoading>(),
          isA<DashboardFailureState>().having(
            (state) => state.message,
            'message',
            'kpis failed',
          ),
        ];
        expectLater(dashboardBloc.stream, emitsInOrder(expected));

        // act
        dashboardBloc.add(LoadDashboardRequested());
      },
    );

    test(
      'should emit [DashboardLoading, DashboardFailureState] when trend fails',
      () async {
        // arrange
        when(
          () => mockGetKpisUsecase.call(any()),
        ).thenAnswer((_) async => Right(tKpiStats));
        when(() => mockGetAttendanceTrendUsecase.call(any())).thenAnswer(
          (_) async => Left(ServerFailure(message: 'trend failed')),
        );

        // assert later
        final expected = [
          isA<DashboardLoading>(),
          isA<DashboardFailureState>().having(
            (state) => state.message,
            'message',
            'trend failed',
          ),
        ];
        expectLater(dashboardBloc.stream, emitsInOrder(expected));

        // act
        dashboardBloc.add(LoadDashboardRequested());
      },
    );

    test(
      'should emit failure when department stats fail',
      () async {
        // arrange
        when(
          () => mockGetKpisUsecase.call(any()),
        ).thenAnswer((_) async => Right(tKpiStats));
        when(
          () => mockGetAttendanceTrendUsecase.call(any()),
        ).thenAnswer((_) async => Right(tWeeklyTrend));
        when(
          () => mockGetDepartmentStatsUsecase.call(any()),
        ).thenAnswer(
          (_) async => Left(ServerFailure(message: 'departments failed')),
        );

        // assert later
        final expected = [
          isA<DashboardLoading>(),
          isA<DashboardFailureState>().having(
            (state) => state.message,
            'message',
            'departments failed',
          ),
        ];
        expectLater(dashboardBloc.stream, emitsInOrder(expected));

        // act
        dashboardBloc.add(LoadDashboardRequested());
      },
    );
  });

  group('DashboardBloc - TrendPeriodChanged', () {
    test(
      'should emit DashboardLoaded with new trend and period when successful',
      () async {
        // arrange: reach the loaded state first
        when(
          () => mockGetKpisUsecase.call(any()),
        ).thenAnswer((_) async => Right(tKpiStats));
        when(
          () => mockGetAttendanceTrendUsecase.call(any()),
        ).thenAnswer((_) async => Right(tWeeklyTrend));
        dashboardBloc.add(LoadDashboardRequested());
        await pumpEventQueue();
        expect(dashboardBloc.state, isA<DashboardLoaded>());

        // arrange: monthly trend requested next
        when(
          () => mockGetAttendanceTrendUsecase.call(any()),
        ).thenAnswer((_) async => Right(tMonthlyTrend));

        // assert later
        final expected = [
          isA<DashboardLoaded>()
              .having((state) => state.kpis, 'kpis', tKpiStats)
              .having((state) => state.trend, 'trend', tMonthlyTrend)
              .having((state) => state.period, 'period', TrendPeriod.monthly)
              .having(
                (state) => state.departments,
                'departments',
                tDepartments,
              )
              .having((state) => state.alerts, 'alerts', tAlerts),
        ];
        expectLater(dashboardBloc.stream, emitsInOrder(expected));

        // act
        dashboardBloc.add(TrendPeriodChanged(period: TrendPeriod.monthly));
      },
    );
  });
}
