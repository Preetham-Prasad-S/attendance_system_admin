import 'package:attendance_system_admin/core/failure.dart';
import 'package:attendance_system_admin/features/dashboard/data/datasources/dashboard_datasource.dart';
import 'package:attendance_system_admin/features/dashboard/domain/entities/dashboard_entities.dart';
import 'package:attendance_system_admin/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:fpdart/fpdart.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardDatasource _dashboardDatasource;

  DashboardRepositoryImpl({required DashboardDatasource dashboardDatasource})
    : _dashboardDatasource = dashboardDatasource;

  @override
  Future<Either<Failure, KpiStats>> getKpis() async {
    try {
      return Right(await _dashboardDatasource.fetchKpis());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DailyAttendancePoint>>> getAttendanceTrend(
    int days,
  ) async {
    try {
      return Right(await _dashboardDatasource.fetchAttendanceTrend(days));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DepartmentStat>>> getDepartmentStats() async {
    try {
      return Right(await _dashboardDatasource.fetchDepartmentStats());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DashboardAlert>>> getAlerts() async {
    try {
      return Right(await _dashboardDatasource.fetchAlerts());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
