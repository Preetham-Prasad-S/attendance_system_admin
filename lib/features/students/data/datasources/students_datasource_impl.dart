import 'package:attendance_system_admin/features/students/data/datasources/students_datasource.dart';
import 'package:attendance_system_admin/features/students/domain/entities/students_entities.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudentsDatasourceImpl implements StudentsDatasource {
  final SupabaseClient _supabaseClient;

  StudentsDatasourceImpl({required SupabaseClient supabaseClient})
    : _supabaseClient = supabaseClient;

  /// Window shared by the KPI cards, table summaries, and the 30-day log.
  static const int complianceWindowDays = 30;

  /// Window behind the "+N this term" KPI card.
  static const int termWindowDays = 90;

  static const AttendanceSummary _emptySummary = AttendanceSummary(
    recordsTotal: 0,
    presentDays: 0,
    lateDays: 0,
    absentDays: 0,
    leaveDays: 0,
  );

  static String _isoDate(DateTime date) =>
      date.toIso8601String().substring(0, 10);

  static String? _emptyToNull(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  /// Removes characters that would break PostgREST `or`/`ilike` syntax.
  static String _sanitizeSearch(String raw) =>
      raw.replaceAll(RegExp(r"['%,*()]"), '').trim();

  @override
  Future<DirectoryKpis> fetchDirectoryKpis() async {
    final today = DateTime.now();
    final windowStart = today.subtract(
      const Duration(days: complianceWindowDays - 1),
    );
    final termStart = today.subtract(const Duration(days: termWindowDays));

    final studentRows = await _supabaseClient
        .from('students')
        .select('id, status, created_at, department');
    final windowRows = await _supabaseClient
        .from('attendance_records')
        .select('student_id, status')
        .gte('date', _isoDate(windowStart))
        .lte('date', _isoDate(today));

    final summaries = _summariesFromRecords(windowRows);

    var totalEnrolled = 0;
    var newThisTerm = 0;
    var compliant = 0;
    var defaulter = 0;
    var critical = 0;
    final departments = <String>{};

    for (final row in studentRows) {
      final department = row['department'] as String?;
      if (department != null && department.isNotEmpty) {
        departments.add(department);
      }
      if (row['status'] != 'active') continue;

      totalEnrolled += 1;
      final createdAt = DateTime.tryParse(row['created_at'] as String? ?? '');
      if (createdAt != null && createdAt.isAfter(termStart)) {
        newThisTerm += 1;
      }

      final summary = summaries[row['id'] as String];
      if (summary == null) continue;
      final tier = summary.tier;
      if (tier == ComplianceTier.noData) continue;
      if (tier.isCompliant) {
        compliant += 1;
      } else {
        defaulter += 1;
        if (tier == ComplianceTier.critical) critical += 1;
      }
    }

    final sortedDepartments = departments.toList()..sort();
    return DirectoryKpis(
      totalEnrolled: totalEnrolled,
      newThisTerm: newThisTerm,
      compliantCount: compliant,
      defaulterCount: defaulter,
      criticalCount: critical,
      availableDepartments: sortedDepartments,
    );
  }

  @override
  Future<DirectoryPage> fetchStudentsPage(DirectoryFilters filters) async {
    Set<String>? criticalIds;
    if (filters.criticalOnly) {
      criticalIds = await _fetchCriticalStudentIds();
      if (criticalIds.isEmpty) {
        return const DirectoryPage(entries: [], totalCount: 0);
      }
    }

    PostgrestFilterBuilder<List<Map<String, dynamic>>> query = _supabaseClient
        .from('students')
        .select('id, student_no, name, email, department, status, created_at');

    final search = _sanitizeSearch(filters.searchQuery);
    if (search.isNotEmpty) {
      query = query.or(
        'name.ilike.*$search*,student_no.ilike.*$search*,email.ilike.*$search*',
      );
    }
    if (filters.department != null && filters.department!.isNotEmpty) {
      query = query.eq('department', filters.department!);
    }
    if (filters.status != null) {
      query = query.eq('status', filters.status!);
    }
    if (criticalIds != null) {
      query = query.inFilter('id', criticalIds.toList());
    }

    final from = filters.page * filters.pageSize;
    final response = await query
        .order('name')
        .range(from, from + filters.pageSize - 1)
        .count(CountOption.exact);

    final entries = await _buildEntries(response.data);
    return DirectoryPage(entries: entries, totalCount: response.count);
  }

  @override
  Future<List<AttendanceLogDay>> fetchAttendanceLog(
    String studentId,
    int days,
  ) async {
    final today = DateTime.now();
    final start = today.subtract(Duration(days: days - 1));

    final rows = await _supabaseClient
        .from('attendance_records')
        .select('date, status')
        .eq('student_id', studentId)
        .gte('date', _isoDate(start))
        .lte('date', _isoDate(today))
        .order('date');

    final statusByDate = <String, LogStatus>{
      for (final row in rows)
        row['date'] as String: _toLogStatus(row['status'] as String?),
    };

    return [
      for (var i = 0; i < days; i++)
        AttendanceLogDay(
          date: start.add(Duration(days: i)),
          status: statusByDate[_isoDate(start.add(Duration(days: i)))] ??
              LogStatus.off,
        ),
    ];
  }

  @override
  Future<Student> addStudent(AddStudentParams params) async {
    final organization = await _resolveOrganization();

    try {
      final row = await _supabaseClient
          .from('students')
          .insert({
            'organization': organization,
            'student_no': params.studentNo.trim(),
            'name': params.name.trim(),
            'email': _emptyToNull(params.email),
            'department': _emptyToNull(params.department),
            'status': params.status,
          })
          .select('id, student_no, name, email, department, status, created_at')
          .single();
      return _studentFromRow(row);
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw Exception(
          'A student with roll number "${params.studentNo.trim()}" already exists',
        );
      }
      rethrow;
    }
  }

  /// Active-student ids below the 65% critical threshold in the window.
  Future<Set<String>> _fetchCriticalStudentIds() async {
    final today = DateTime.now();
    final windowStart = today.subtract(
      const Duration(days: complianceWindowDays - 1),
    );

    final studentRows = await _supabaseClient
        .from('students')
        .select('id, status');
    final windowRows = await _supabaseClient
        .from('attendance_records')
        .select('student_id, status')
        .gte('date', _isoDate(windowStart))
        .lte('date', _isoDate(today));

    final summaries = _summariesFromRecords(windowRows);
    final ids = <String>{};
    for (final row in studentRows) {
      if (row['status'] != 'active') continue;
      final summary = summaries[row['id'] as String];
      if (summary?.tier == ComplianceTier.critical) {
        ids.add(row['id'] as String);
      }
    }
    return ids;
  }

  /// Builds table entries for [studentRows] with window summaries and the
  /// most recent attendance record (method + timestamp) per student.
  Future<List<StudentDirectoryEntry>> _buildEntries(
    List<Map<String, dynamic>> studentRows,
  ) async {
    if (studentRows.isEmpty) return const [];

    final ids = [for (final row in studentRows) row['id'] as String];
    final today = DateTime.now();
    final windowStart = today.subtract(
      const Duration(days: complianceWindowDays - 1),
    );

    final records = await _supabaseClient
        .from('attendance_records')
        .select('student_id, status, date, method, created_at')
        .inFilter('student_id', ids)
        .gte('date', _isoDate(windowStart))
        .lte('date', _isoDate(today))
        .order('date', ascending: true);

    final summaries = _summariesFromRecords(records);

    // Rows are ordered by date ascending, so the last row per student is
    // the most recent record (one record per student per date).
    final latestByStudent = <String, Map<String, dynamic>>{};
    for (final row in records) {
      latestByStudent[row['student_id'] as String] = row;
    }

    return [
      for (final row in studentRows)
        StudentDirectoryEntry(
          student: _studentFromRow(row),
          summary: summaries[row['id'] as String] ?? _emptySummary,
          lastMethod: latestByStudent[row['id'] as String]?['method']
              as String?,
          lastRecordedAt: DateTime.tryParse(
            latestByStudent[row['id'] as String]?['created_at'] as String? ??
                '',
          ),
        ),
    ];
  }

  /// Groups window records into one [AttendanceSummary] per student.
  static Map<String, AttendanceSummary> _summariesFromRecords(
    Iterable<Map<String, dynamic>> rows,
  ) {
    // [present, late, absent, on_leave] per student id.
    final counts = <String, List<int>>{};
    for (final row in rows) {
      final id = row['student_id'] as String;
      final entry = counts[id] ?? [0, 0, 0, 0];
      switch (row['status'] as String?) {
        case 'present':
          entry[0] += 1;
        case 'late':
          entry[1] += 1;
        case 'absent':
          entry[2] += 1;
        case 'on_leave':
          entry[3] += 1;
      }
      counts[id] = entry;
    }

    return {
      for (final entry in counts.entries)
        entry.key: AttendanceSummary(
          recordsTotal:
              entry.value[0] +
              entry.value[1] +
              entry.value[2] +
              entry.value[3],
          presentDays: entry.value[0],
          lateDays: entry.value[1],
          absentDays: entry.value[2],
          leaveDays: entry.value[3],
        ),
    };
  }

  static LogStatus _toLogStatus(String? status) => switch (status) {
    'present' => LogStatus.present,
    'late' => LogStatus.late,
    'absent' => LogStatus.absent,
    'on_leave' => LogStatus.onLeave,
    _ => LogStatus.off,
  };

  static Student _studentFromRow(Map<String, dynamic> row) => Student(
    id: row['id'] as String,
    studentNo: row['student_no'] as String,
    name: row['name'] as String,
    email: row['email'] as String?,
    department: row['department'] as String?,
    status: row['status'] as String,
    createdAt: DateTime.tryParse(row['created_at'] as String? ?? '') ??
        DateTime.now(),
  );

  /// Resolves the caller's organization from their profile, falling back to
  /// an existing student row (both RLS-scoped to the caller's org).
  Future<String> _resolveOrganization() async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final profile = await _supabaseClient
        .from('profiles')
        .select('organization')
        .eq('id', user.id)
        .maybeSingle();
    final organization = profile?['organization'] as String?;
    if (organization != null && organization.isNotEmpty) {
      return organization;
    }

    final existing = await _supabaseClient
        .from('students')
        .select('organization')
        .limit(1)
        .maybeSingle();
    final fallback = existing?['organization'] as String?;
    if (fallback != null && fallback.isNotEmpty) return fallback;

    throw Exception('Could not resolve organization');
  }
}
