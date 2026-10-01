import 'package:attendance_system_admin/features/dashboard/domain/entities/dashboard_entities.dart';

/// Remote data contract for dashboard queries.
abstract interface class DashboardDatasource {
  /// Aggregates the KPI figures for the stats row.
  Future<KpiStats> fetchKpis();

  /// Aggregates daily attendance for the last [days] days.
  Future<List<DailyAttendancePoint>> fetchAttendanceTrend(int days);
}
