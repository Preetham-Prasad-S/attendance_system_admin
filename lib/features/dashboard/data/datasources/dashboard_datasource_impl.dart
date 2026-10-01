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

  static DateTime _parseIsoDate(String iso) {
    final parts = iso.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }
}
