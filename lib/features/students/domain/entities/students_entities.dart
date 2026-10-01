// ignore_for_file: public_member_api_docs, sort_constructors_first

/// Compliance classification of a student's attendance percentage.
enum ComplianceTier {
  excellent('Excellent'),
  good('Good'),
  compliant('Compliant'),
  borderline('Borderline'),
  critical('Critical'),
  noData('No data');

  const ComplianceTier(this.label);

  /// Display label for the progress-bar caption in the table row.
  final String label;

  /// Label for the row status chip (Regular / Defaulter / Critical).
  String get chipLabel => switch (this) {
    ComplianceTier.excellent ||
    ComplianceTier.good ||
    ComplianceTier.compliant =>
      'Regular',
    ComplianceTier.borderline => 'Defaulter',
    ComplianceTier.critical => 'Critical',
    ComplianceTier.noData => '—',
  };

  /// Whether the student meets the 75% institutional minimum.
  bool get isCompliant =>
      this == ComplianceTier.excellent ||
      this == ComplianceTier.good ||
      this == ComplianceTier.compliant;
}

/// A student's attendance aggregate over the compliance window.
///
/// Percentage rule (docs/ui/student-directory/PLAN.md §4):
/// `pct = (present + late) / (records - on_leave) * 100` — late counts as
/// attended, excused leave is excluded from the denominator; a zero
/// denominator yields [ComplianceTier.noData].
class AttendanceSummary {
  final int recordsTotal;
  final int presentDays;
  final int lateDays;
  final int absentDays;
  final int leaveDays;

  const AttendanceSummary({
    required this.recordsTotal,
    required this.presentDays,
    required this.lateDays,
    required this.absentDays,
    required this.leaveDays,
  });

  /// Sessions attended (present + late).
  int get attendedDays => presentDays + lateDays;

  /// Required sessions: total records minus excused leave.
  int get requiredDays => recordsTotal - leaveDays;

  /// Attendance percentage over the compliance window.
  double get presentPct =>
      requiredDays <= 0 ? 0 : (attendedDays / requiredDays) * 100;

  /// Compliance tier derived from [presentPct].
  ComplianceTier get tier {
    if (requiredDays <= 0) return ComplianceTier.noData;
    final pct = presentPct;
    if (pct >= 90) return ComplianceTier.excellent;
    if (pct >= 80) return ComplianceTier.good;
    if (pct >= 75) return ComplianceTier.compliant;
    if (pct >= 65) return ComplianceTier.borderline;
    return ComplianceTier.critical;
  }

  @override
  bool operator ==(Object other) =>
      other is AttendanceSummary &&
      other.recordsTotal == recordsTotal &&
      other.presentDays == presentDays &&
      other.lateDays == lateDays &&
      other.absentDays == absentDays &&
      other.leaveDays == leaveDays;

  @override
  int get hashCode =>
      Object.hash(recordsTotal, presentDays, lateDays, absentDays, leaveDays);
}

/// One row of the `students` table.
class Student {
  final String id;
  final String studentNo;
  final String name;
  final String? email;
  final String? department;

  /// Raw `student_status` value: 'active' or 'inactive'.
  final String status;
  final DateTime createdAt;

  const Student({
    required this.id,
    required this.studentNo,
    required this.name,
    required this.email,
    required this.department,
    required this.status,
    required this.createdAt,
  });

  bool get isActive => status == 'active';

  /// First/last name initials for the avatar (e.g. "Aarav Patel" → "AP").
  String get initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  @override
  bool operator ==(Object other) =>
      other is Student &&
      other.id == id &&
      other.studentNo == studentNo &&
      other.name == name &&
      other.email == email &&
      other.department == department &&
      other.status == status &&
      other.createdAt == createdAt;

  @override
  int get hashCode => Object.hash(
    id,
    studentNo,
    name,
    email,
    department,
    status,
    createdAt,
  );
}

/// A table row: student profile + compliance aggregate + latest telemetry.
class StudentDirectoryEntry {
  final Student student;
  final AttendanceSummary summary;

  /// `method` of the student's most recent attendance record, if any.
  final String? lastMethod;

  /// When the student's most recent attendance record was written.
  final DateTime? lastRecordedAt;

  const StudentDirectoryEntry({
    required this.student,
    required this.summary,
    required this.lastMethod,
    required this.lastRecordedAt,
  });

  @override
  bool operator ==(Object other) =>
      other is StudentDirectoryEntry &&
      other.student == student &&
      other.summary == summary &&
      other.lastMethod == lastMethod &&
      other.lastRecordedAt == lastRecordedAt;

  @override
  int get hashCode =>
      Object.hash(student, summary, lastMethod, lastRecordedAt);
}

/// Directory KPI cards (design: Total Enrolled / Compliant / Defaulters /
/// Critical Warning) plus the department filter options.
///
/// All counts cover **active** students only; compliance counts are computed
/// over the 30-day window and ignore students with no required sessions.
class DirectoryKpis {
  final int totalEnrolled;
  final int newThisTerm;
  final int compliantCount;
  final int defaulterCount;
  final int criticalCount;

  /// Distinct department names for the filter dropdown (alphabetical).
  final List<String> availableDepartments;

  const DirectoryKpis({
    required this.totalEnrolled,
    required this.newThisTerm,
    required this.compliantCount,
    required this.defaulterCount,
    required this.criticalCount,
    required this.availableDepartments,
  });

  double get compliantPct =>
      totalEnrolled == 0 ? 0 : (compliantCount / totalEnrolled) * 100;

  double get defaulterPct =>
      totalEnrolled == 0 ? 0 : (defaulterCount / totalEnrolled) * 100;

  double get criticalPct =>
      totalEnrolled == 0 ? 0 : (criticalCount / totalEnrolled) * 100;

  @override
  bool operator ==(Object other) =>
      other is DirectoryKpis &&
      other.totalEnrolled == totalEnrolled &&
      other.newThisTerm == newThisTerm &&
      other.compliantCount == compliantCount &&
      other.defaulterCount == defaulterCount &&
      other.criticalCount == criticalCount &&
      _listEquals(other.availableDepartments, availableDepartments);

  @override
  int get hashCode => Object.hash(
    totalEnrolled,
    newThisTerm,
    compliantCount,
    defaulterCount,
    criticalCount,
    Object.hashAll(availableDepartments),
  );
}

/// Server-side filter + pagination state of the directory table.
class DirectoryFilters {
  final String searchQuery;

  /// `null` = all departments; otherwise a `students.department` value.
  final String? department;

  /// `null` = all records; otherwise 'active' / 'inactive'.
  final String? status;

  /// Quick filter: only critical defaulters (<65%).
  final bool criticalOnly;

  /// Zero-based page index.
  final int page;
  final int pageSize;

  const DirectoryFilters({
    this.searchQuery = '',
    this.department,
    this.status,
    this.criticalOnly = false,
    this.page = 0,
    this.pageSize = 25,
  });

  static const initial = DirectoryFilters();

  DirectoryFilters copyWith({
    String? searchQuery,
    String? department,
    String? status,
    bool? criticalOnly,
    int? page,
    int? pageSize,
  }) {
    return DirectoryFilters(
      searchQuery: searchQuery ?? this.searchQuery,
      department: department ?? this.department,
      status: status ?? this.status,
      criticalOnly: criticalOnly ?? this.criticalOnly,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  /// Copy with [department] / [status] explicitly settable to `null` (All).
  DirectoryFilters copyWithNullable({
    Object? department = _sentinel,
    Object? status = _sentinel,
    String? searchQuery,
    bool? criticalOnly,
    int? page,
    int? pageSize,
  }) {
    return DirectoryFilters(
      searchQuery: searchQuery ?? this.searchQuery,
      department: identical(department, _sentinel)
          ? this.department
          : department as String?,
      status: identical(status, _sentinel) ? this.status : status as String?,
      criticalOnly: criticalOnly ?? this.criticalOnly,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is DirectoryFilters &&
      other.searchQuery == searchQuery &&
      other.department == department &&
      other.status == status &&
      other.criticalOnly == criticalOnly &&
      other.page == page &&
      other.pageSize == pageSize;

  @override
  int get hashCode => Object.hash(
    searchQuery,
    department,
    status,
    criticalOnly,
    page,
    pageSize,
  );
}

/// One fetched page of the directory table.
class DirectoryPage {
  final List<StudentDirectoryEntry> entries;

  /// Total rows matching the filters (across all pages).
  final int totalCount;

  const DirectoryPage({required this.entries, required this.totalCount});

  @override
  bool operator ==(Object other) =>
      other is DirectoryPage &&
      _listEquals(other.entries, entries) &&
      other.totalCount == totalCount;

  @override
  int get hashCode => Object.hash(Object.hashAll(entries), totalCount);
}

/// Per-day status shown in the 30-day attendance log grid.
enum LogStatus { present, late, absent, onLeave, off }

/// One cell of the 30-day attendance log.
class AttendanceLogDay {
  final DateTime date;
  final LogStatus status;

  const AttendanceLogDay({required this.date, required this.status});

  @override
  bool operator ==(Object other) =>
      other is AttendanceLogDay && other.date == date && other.status == status;

  @override
  int get hashCode => Object.hash(date, status);
}

/// Parameters for `GetStudentsPageUsecase`.
// (DirectoryFilters is used directly as the params type.)

/// Parameters for `GetStudentAttendanceLogUsecase`.
class AttendanceLogParams {
  final String studentId;
  final int days;

  const AttendanceLogParams({required this.studentId, this.days = 30});

  @override
  bool operator ==(Object other) =>
      other is AttendanceLogParams &&
      other.studentId == studentId &&
      other.days == days;

  @override
  int get hashCode => Object.hash(studentId, days);
}

/// Parameters for `AddStudentUsecase`.
class AddStudentParams {
  final String name;
  final String studentNo;
  final String? email;
  final String? department;

  /// 'active' or 'inactive'.
  final String status;

  const AddStudentParams({
    required this.name,
    required this.studentNo,
    this.email,
    this.department,
    this.status = 'active',
  });

  @override
  bool operator ==(Object other) =>
      other is AddStudentParams &&
      other.name == name &&
      other.studentNo == studentNo &&
      other.email == email &&
      other.department == department &&
      other.status == status;

  @override
  int get hashCode =>
      Object.hash(name, studentNo, email, department, status);
}

const _sentinel = Object();

bool _listEquals(List<Object?> a, List<Object?> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
