import 'package:attendance_system_admin/core/failure.dart';
import 'package:attendance_system_admin/features/dashboard/data/datasources/dashboard_datasource.dart';
import 'package:attendance_system_admin/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:attendance_system_admin/features/dashboard/domain/entities/dashboard_entities.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDashboardDatasource extends Mock implements DashboardDatasource {}

void main() {
  late DashboardRepositoryImpl dashboardRepositoryImpl;
  late MockDashboardDatasource mockDashboardDatasource;

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

  setUp(() {
    mockDashboardDatasource = MockDashboardDatasource();
    dashboardRepositoryImpl = DashboardRepositoryImpl(
      dashboardDatasource: mockDashboardDatasource,
    );
  });

  group('getKpis', () {
    test(
      'should return Right(KpiStats) when call to datasource is successful',
      () async {
        // arrange
        when(
          () => mockDashboardDatasource.fetchKpis(),
        ).thenAnswer((_) async => tKpiStats);

        // act
        final result = await dashboardRepositoryImpl.getKpis();

        // assert
        verify(() => mockDashboardDatasource.fetchKpis()).called(1);
        expect(result.isRight(), true);

        result.fold((failure) => fail('Should not fail'), (stats) {
          expect(stats, tKpiStats);
        });
      },
    );

    test(
      'should return ServerFailure when call to datasource throws',
      () async {
        // arrange
        when(
          () => mockDashboardDatasource.fetchKpis(),
        ).thenThrow(Exception('boom'));

        // act
        final result = await dashboardRepositoryImpl.getKpis();

        // assert
        verify(() => mockDashboardDatasource.fetchKpis()).called(1);
        expect(result.isLeft(), true);

        result.fold((failure) {
          expect(failure, isA<ServerFailure>());
        }, (_) => fail('Should fail'));
      },
    );
  });

  group('getAttendanceTrend', () {
    test(
      'should return Right(trend) when call to datasource is successful',
      () async {
        // arrange
        when(
          () => mockDashboardDatasource.fetchAttendanceTrend(7),
        ).thenAnswer((_) async => tTrend);

        // act
        final result = await dashboardRepositoryImpl.getAttendanceTrend(7);

        // assert
        verify(() => mockDashboardDatasource.fetchAttendanceTrend(7)).called(1);
        expect(result.isRight(), true);

        result.fold((failure) => fail('Should not fail'), (points) {
          expect(points, tTrend);
        });
      },
    );

    test(
      'should return ServerFailure when call to datasource throws',
      () async {
        // arrange
        when(
          () => mockDashboardDatasource.fetchAttendanceTrend(7),
        ).thenThrow(Exception('boom'));

        // act
        final result = await dashboardRepositoryImpl.getAttendanceTrend(7);

        // assert
        verify(() => mockDashboardDatasource.fetchAttendanceTrend(7)).called(1);
        expect(result.isLeft(), true);

        result.fold((failure) {
          expect(failure, isA<ServerFailure>());
        }, (_) => fail('Should fail'));
      },
    );
  });
}
