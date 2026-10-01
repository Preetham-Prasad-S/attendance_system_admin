import 'package:attendance_system_admin/features/dashboard/domain/entities/dashboard_entities.dart';

/// Remote data contract for dashboard queries.
abstract interface class DashboardDatasource {
  /// Aggregates the KPI figures for the stats row.
  Future<KpiStats> fetchKpis();

  /// Aggregates daily attendance for the last [days] days.
  Future<List<DailyAttendancePoint>> fetchAttendanceTrend(int days);

  /// Aggregates today's attendance per department.
  Future<List<DepartmentStat>> fetchDepartmentStats();

  /// Derives operational alerts from attendance data.
  Future<List<DashboardAlert>> fetchAlerts();
}
