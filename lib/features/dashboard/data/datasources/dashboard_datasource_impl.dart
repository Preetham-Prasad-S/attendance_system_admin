import 'package:attendance_system_admin/features/dashboard/data/datasources/dashboard_datasource.dart';
import 'package:attendance_system_admin/features/dashboard/domain/entities/dashboard_entities.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardDatasourceImpl implements DashboardDatasource {
  final SupabaseClient _supabaseClient;

  DashboardDatasourceImpl({required SupabaseClient supabaseClient})
    : _supabaseClient = supabaseClient;

  static String _isoDate(DateTime date) =>
      date.toIso8601String().substring(0, 10);

  @override
  Future<KpiStats> fetchKpis() async {
    final studentsCount = await _supabaseClient
        .from('students')
        .select('id')
        .count(CountOption.exact);
    final staffCount = await _supabaseClient
        .from('staff')
        .select('id')
        .count(CountOption.exact);
    final departmentRows = await _supabaseClient
        .from('students')
        .select('department');
    final todayRows = await _supabaseClient
        .from('attendance_records')
        .select('status')
        .eq('date', _isoDate(DateTime.now()));

    var present = 0;
    var absent = 0;
    var late = 0;
    var onLeave = 0;
    for (final row in todayRows) {
      switch (row['status'] as String?) {
        case 'present':
          present++;
        case 'absent':
          absent++;
        case 'late':
          late++;
        case 'on_leave':
          onLeave++;
      }
    }

    final departments = <String>{};
    for (final row in departmentRows) {
      final department = row['department'] as String?;
      if (department != null && department.isNotEmpty) {
        departments.add(department);
      }
    }

    return KpiStats(
      totalStudents: studentsCount.count,
      totalStaff: staffCount.count,
      departmentCount: departments.length,
      presentToday: present,
      absentToday: absent,
      lateToday: late,
      onLeaveToday: onLeave,
      recordsToday: todayRows.length,
    );
  }

  @override
  Future<List<DailyAttendancePoint>> fetchAttendanceTrend(int days) async {
    final today = DateTime.now();
    final start = today.subtract(Duration(days: days - 1));

    final rows = await _supabaseClient
        .from('attendance_records')
        .select('date, status')
        .gte('date', _isoDate(start))
        .lte('date', _isoDate(today))
        .order('date');

    // [total records, present records] per ISO date, in date order.
    final totalsByDate = <String, List<int>>{};
    for (final row in rows) {
      final date = row['date'] as String;
      final entry = totalsByDate[date] ?? [0, 0];
      entry[0] += 1;
      if (row['status'] == 'present') {
        entry[1] += 1;
      }
      totalsByDate[date] = entry;
    }

    return [
      for (final entry in totalsByDate.entries)
        DailyAttendancePoint(
          date: _parseIsoDate(entry.key),
          total: entry.value[0],
          present: entry.value[1],
        ),
    ];
  }

  @override
  Future<List<DepartmentStat>> fetchDepartmentStats() async {
    final studentRows = await _supabaseClient
        .from('students')
        .select('id, department');
    final todayRows = await _supabaseClient
        .from('attendance_records')
        .select('student_id, status')
        .eq('date', _isoDate(DateTime.now()));

    final departmentByStudent = <String, String?>{
      for (final row in studentRows)
        row['id'] as String: row['department'] as String?,
    };

    final recordsByDepartment = <String, int>{};
    final presentByDepartment = <String, int>{};
    for (final row in todayRows) {
      final department = departmentByStudent[row['student_id']];
      if (department == null || department.isEmpty) continue;
      recordsByDepartment[department] =
          (recordsByDepartment[department] ?? 0) + 1;
      if (row['status'] == 'present') {
        presentByDepartment[department] =
            (presentByDepartment[department] ?? 0) + 1;
      }
    }

    final departments = <String>{
      for (final row in studentRows)
        if ((row['department'] as String?)?.isNotEmpty ?? false)
          row['department'] as String,
    };

    final stats = [
      for (final name in departments)
        DepartmentStat(
          name: name,
          recordsToday: recordsByDepartment[name] ?? 0,
          presentToday: presentByDepartment[name] ?? 0,
        ),
    ];
    stats.sort((a, b) {
      final byPct = b.presentPct.compareTo(a.presentPct);
      return byPct != 0 ? byPct : a.name.compareTo(b.name);
    });
    return stats;
  }

  @override
  Future<List<DashboardAlert>> fetchAlerts() async {
    final today = DateTime.now();
    final windowStart = today.subtract(const Duration(days: 6));

    final studentRows = await _supabaseClient
        .from('students')
        .select('id, department');
    final windowRows = await _supabaseClient
        .from('attendance_records')
        .select('student_id, status, date')
        .gte('date', _isoDate(windowStart))
        .lte('date', _isoDate(today));

    final departmentByStudent = <String, String?>{
      for (final row in studentRows)
        row['id'] as String: row['department'] as String?,
    };

    // Per-student totals over the 7-day compliance window.
    final totalsByStudent = <String, List<int>>{}; // [records, present]
    var absentToday = 0;
    var recordsToday = 0;
    final todayIso = _isoDate(today);
    for (final row in windowRows) {
      final studentId = row['student_id'] as String;
      final entry = totalsByStudent[studentId] ?? [0, 0];
      entry[0] += 1;
      if (row['status'] == 'present') entry[1] += 1;
      totalsByStudent[studentId] = entry;

      if (row['date'] == todayIso) {
        recordsToday += 1;
        if (row['status'] == 'absent') absentToday += 1;
      }
    }

    var belowThreshold = 0;
    final offendersByDepartment = <String, int>{};
    for (final entry in totalsByStudent.entries) {
      final total = entry.value[0];
      final present = entry.value[1];
      if (total == 0 || present / total >= 0.75) continue;
      belowThreshold += 1;
      final department = departmentByStudent[entry.key];
      if (department != null && department.isNotEmpty) {
        offendersByDepartment[department] =
            (offendersByDepartment[department] ?? 0) + 1;
      }
    }

    String? topOffendingDepartment;
    var topOffenderCount = 0;
    for (final entry in offendersByDepartment.entries) {
      if (entry.value > topOffenderCount) {
        topOffendingDepartment = entry.key;
        topOffenderCount = entry.value;
      }
    }

    final alerts = <DashboardAlert>[
      if (belowThreshold > 0)
        DashboardAlert(
          type: 'THRESHOLD BREACH',
          title: topOffendingDepartment == null
              ? '$belowThreshold Students below 75%'
              : '$belowThreshold Students below 75% in $topOffendingDepartment',
          description:
              'Attendance below the institutional minimum over the last '
              '7 days. Automated SMS warnings queued for parent dispatch.',
          time: 'Last 7 days',
          actionLabel: 'Review & Notify Parents',
          actionStyle: AlertActionStyle.filled,
        ),
      if (absentToday > 0)
        DashboardAlert(
          type: 'ABSENCE WATCH',
          title: '$absentToday Students Absent Today',
          description:
              'Absentee rate '
              '${(absentToday / recordsToday * 100).toStringAsFixed(1)}% '
              'across $recordsToday recorded sessions.',
          time: 'Today',
          actionLabel: 'Open Daily Attendance',
          actionStyle: AlertActionStyle.outlined,
        ),
    ];
    return alerts;
  }

  static DateTime _parseIsoDate(String iso) {
    final parts = iso.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }
}
