// ignore_for_file: public_member_api_docs, sort_constructors_first

/// Aggregated KPI figures shown in the dashboard stats row.
class KpiStats {
  final int totalStudents;
  final int totalStaff;
  final int departmentCount;
  final int presentToday;
  final int absentToday;
  final int lateToday;
  final int onLeaveToday;
  final int recordsToday;

  const KpiStats({
    required this.totalStudents,
    required this.totalStaff,
    required this.departmentCount,
    required this.presentToday,
    required this.absentToday,
    required this.lateToday,
    required this.onLeaveToday,
    required this.recordsToday,
  });

  /// Share of today's attendance records marked present, in percent.
  double get presentTodayPct =>
      recordsToday == 0 ? 0 : (presentToday / recordsToday) * 100;

  @override
  bool operator ==(Object other) =>
      other is KpiStats &&
      other.totalStudents == totalStudents &&
      other.totalStaff == totalStaff &&
      other.departmentCount == departmentCount &&
      other.presentToday == presentToday &&
      other.absentToday == absentToday &&
      other.lateToday == lateToday &&
      other.onLeaveToday == onLeaveToday &&
      other.recordsToday == recordsToday;

  @override
  int get hashCode => Object.hash(
        totalStudents,
        totalStaff,
        departmentCount,
        presentToday,
        absentToday,
        lateToday,
        onLeaveToday,
        recordsToday,
      );
}

/// One calendar day of aggregated attendance (trend chart point).
class DailyAttendancePoint {
  final DateTime date;
  final int total;
  final int present;

  const DailyAttendancePoint({
    required this.date,
    required this.total,
    required this.present,
  });

  /// Share of records marked present on [date], in percent.
  double get presentPct => total == 0 ? 0 : (present / total) * 100;

  @override
  bool operator ==(Object other) =>
      other is DailyAttendancePoint &&
      other.date == date &&
      other.total == total &&
      other.present == present;

  @override
  int get hashCode => Object.hash(date, total, present);
}

/// Selectable range of the attendance trend chart.
enum TrendPeriod {
  weekly('Weekly', 7),
  monthly('Monthly', 30),
  semester('Semester', 90);

  const TrendPeriod(this.label, this.days);

  /// Display label used by the period toggle.
  final String label;

  /// Number of calendar days covered by the period.
  final int days;
}
