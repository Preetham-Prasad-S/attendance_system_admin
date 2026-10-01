import 'package:attendance_system_admin/core/failure.dart';
import 'package:attendance_system_admin/features/dashboard/domain/entities/dashboard_entities.dart';
import 'package:fpdart/fpdart.dart';

/// Data contract for the dashboard's KPI and trend queries.
abstract interface class DashboardRepository {
  /// Fetches the aggregated KPI figures for the stats row.
  Future<Either<Failure, KpiStats>> getKpis();

  /// Fetches daily attendance aggregates for the last [days] days.
  Future<Either<Failure, List<DailyAttendancePoint>>> getAttendanceTrend(
    int days,
  );
}
