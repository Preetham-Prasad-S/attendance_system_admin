// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';

/// Domain entities for the Faculty Workload & Lecture Coverage screen.
///
/// Everything here is currently fed by `StaffMockData` (see
/// `features/staff/data/mock/staff_mock_data.dart`) because the `public.staff`
/// table has no workload, availability, or coverage columns yet. The entity
/// shapes are chosen so a future `StaffDatasource` can map onto them without
/// touching the presentation layer.
///
/// All time-ish values are pre-formatted `String`s rather than `DateTime`s:
/// the mock layer must stay `const`-constructible, and `intl` formatting is
/// not available in a const context.

/// Honorifics and single-letter initials dropped when deriving avatar letters.
const Set<String> _honorifics = {'Dr', 'Prof', 'Mr', 'Ms', 'Mrs', 'Er'};

/// Up to two initials for the avatar fallback (no photo assets exist).
///
/// "Dr. Rajeshwar Rao" → "RR", "Dr. Lin Chen" → "LC".
String facultyInitials(String name) {
  final parts = name
      .split(RegExp(r'[\s.]+'))
      .where(
        (part) =>
            part.isNotEmpty && !_honorifics.contains(part) && part.length > 1,
      )
      .toList();

  if (parts.isEmpty) {
    final trimmed = name.trim();
    return trimmed.isEmpty ? '?' : trimmed.characters.first.toUpperCase();
  }
  if (parts.length == 1) return parts.first.characters.first.toUpperCase();
  return (parts.first.characters.first + parts.last.characters.first)
      .toUpperCase();
}

/// Aggregate counters shown in the four KPI cards.
class StaffKpis {
  const StaffKpis({
    required this.facultyOnDuty,
    required this.checkedIn,
    required this.totalOnRoster,
    required this.attendanceTrendPercent,
    required this.conductedToday,
    required this.scheduledToday,
    required this.inFlight,
    required this.remaining,
    required this.freeNow,
    required this.onCampus,
    required this.pendingSubstitutes,
    required this.highPrioritySubstitutes,
  });

  final int facultyOnDuty;
  final int checkedIn;
  final int totalOnRoster;

  /// Signed day-over-day delta rendered next to the attendance percentage.
  final double attendanceTrendPercent;

  final int conductedToday;
  final int scheduledToday;

  /// Sessions that have started but not finished.
  final int inFlight;

  /// [scheduledToday] - [conductedToday] - [inFlight].
  final int remaining;

  final int freeNow;
  final int onCampus;
  final int pendingSubstitutes;
  final int highPrioritySubstitutes;

  /// Completion ratio for the "Conducted Today" progress bar.
  double get conductedRatio =>
      scheduledToday == 0 ? 0 : conductedToday / scheduledToday;

  /// "142 / 158 scheduled"
  static String conductedLabel(StaffKpis kpis) =>
      '${kpis.conductedToday} / ${kpis.scheduledToday} scheduled';

  /// "147 of 156 checked in"
  static String checkedInLabel(StaffKpis kpis) =>
      '${kpis.checkedIn} of ${kpis.totalOnRoster} checked in';

  /// "94.2"
  static String attendanceLabel(StaffKpis kpis) =>
      kpis.attendanceTrendPercent.toStringAsFixed(1);
}

/// Current load state of a faculty member, driving the roster card accent.
enum FacultyStatus {
  /// Currently delivering a lecture.
  inLecture,

  /// On campus with no session until the next free slot.
  available,

  /// Approved leave; excluded from the free-faculty count.
  onLeave;

  String get label => switch (this) {
    FacultyStatus.inLecture => 'In Lecture',
    FacultyStatus.available => 'Available',
    FacultyStatus.onLeave => 'On Leave',
  };
}

/// How the roster is laid out; toggled from the page header.
enum StaffViewMode {
  /// Card grid, one card per faculty member.
  rosterGrid,

  /// Dense table with tabular figures.
  detailedTable;

  String get label => switch (this) {
    StaffViewMode.rosterGrid => 'Roster Grid',
    StaffViewMode.detailedTable => 'Detailed Table',
  };
}

/// A lecture the faculty member is delivering right now, or the free-block
/// they are holding instead.
class FacultySession {
  const FacultySession({
    required this.code,
    required this.venue,
    required this.slotLabel,
    required this.isFreeBlock,
    this.availabilityLabel,
  });

  /// "CS-401"
  final String code;

  /// "Hall 302" — empty for a free block.
  final String venue;

  /// "10:00 - 11:30 AM (Slot 2)"
  final String slotLabel;

  /// True when the faculty member has no lecture and is instead parked in a
  /// lounge / office, which is what makes them substitutable.
  final bool isFreeBlock;

  /// "Research Office CS-109" — only for a free block.
  final String? availabilityLabel;
}

/// One roster entry.
class FacultyProfile {
  const FacultyProfile({
    required this.id,
    required this.name,
    required this.designation,
    required this.department,
    required this.status,
    required this.isHeadOfDepartment,
    required this.gateIn,
    required this.currentSession,
    required this.sessionsCompleted,
    required this.sessionsTotal,
    required this.syllabusMatchPercent,
  });

  final String id;
  final String name;

  /// "Professor"
  final String designation;

  final String department;
  final FacultyStatus status;
  final bool isHeadOfDepartment;

  /// Pre-formatted gate check-in, e.g. "Gate A In: 08:14 AM".
  final String gateIn;

  final FacultySession currentSession;
  final int sessionsCompleted;
  final int sessionsTotal;

  /// Match against an open substitution request, 0-100.
  final int syllabusMatchPercent;

  /// "Professor • Dept. of Computer Science"
  String get roleLine => '$designation • Dept. of $department';

  /// "2 of 4 Sessions Complete"
  String get scheduleLoadLabel =>
      '$sessionsCompleted of $sessionsTotal Sessions Complete';

  double get scheduleRatio =>
      sessionsTotal == 0 ? 0 : sessionsCompleted / sessionsTotal;

  /// A faculty member can take a substitution only when they are on campus
  /// and not already teaching.
  bool get isSubstitutable =>
      status == FacultyStatus.available && currentSession.isFreeBlock;

  String get initials => facultyInitials(name);
}

/// Severity of a coverage-board alert.
enum AlertSeverity {
  /// A session is running with nobody teaching it.
  critical,

  /// A session starts soon and its owner is unavailable.
  warning;

  String get badgeLabel => switch (this) {
    AlertSeverity.critical => 'UNATTENDED NOW',
    AlertSeverity.warning => 'UPCOMING',
  };
}

/// Which substitute block of an alert card to render.
enum CoverageStage {
  /// Nobody assigned yet — show the recommendation and the assign actions.
  recommended,

  /// A substitute accepted the request.
  assigned,
}

/// An open lecture-coverage alert on the Class Coverage Board.
class CoverageAlert {
  const CoverageAlert({
    required this.id,
    required this.severity,
    required this.badgeLabel,
    required this.countdownLabel,
    required this.timeRange,
    required this.courseCode,
    required this.courseTitle,
    required this.venueLine,
    required this.stage,
    this.noticeIcon = Icons.error_outline,
    this.noticeLead,
    this.noticeBody,
    this.substituteName,
    this.substituteMeta,
    this.substituteMatchPercent,
    this.substituteAcceptedSms = false,
  });

  final String id;
  final AlertSeverity severity;

  /// Overrides [AlertSeverity.badgeLabel] when the design wants extra copy,
  /// e.g. "UPCOMING (IN 45M)".
  final String badgeLabel;

  /// "(IN 45M)" — appended to [badgeLabel] inside the strip.
  final String countdownLabel;

  /// "10:00 - 11:30 AM"
  final String timeRange;

  final String courseCode;
  final String courseTitle;

  /// "Hall 104 • 64 Students Checked In via Biometrics"
  final String venueLine;

  final CoverageStage stage;

  final IconData? noticeIcon;

  /// "Prof. Sarah Jenkins"
  final String? noticeLead;

  /// "Inbound delay (+38m traffic)"
  final String? noticeBody;

  final String? substituteName;
  final String? substituteMeta;

  /// "98% Syllabus Match" when [stage] is recommended.
  final int? substituteMatchPercent;

  /// Renders the "Accepted SMS" tick when [stage] is assigned.
  final bool substituteAcceptedSms;
}

/// A leave request awaiting a coverage decision.
class LeaveApprovalStub {
  const LeaveApprovalStub({
    required this.id,
    required this.facultyName,
    required this.reasonLine,
    required this.coverageLine,
    this.isCoverageWarning = false,
  });

  final String id;
  final String facultyName;

  /// "Medical • 2 Days (Nov 14-15)"
  final String reasonLine;

  /// "Classes covered by Dr. Rao"
  final String coverageLine;

  /// Renders the coverage line as an unresolved warning.
  final bool isCoverageWarning;
}

/// State of the roster filter bar. All-null fields mean "All".
class StaffFilters {
  const StaffFilters({
    this.searchQuery = '',
    this.department,
    this.designation,
    this.status,
    this.availableOnly = false,
  });

  final String searchQuery;
  final String? department;
  final String? designation;
  final FacultyStatus? status;

  /// When true, keeps only faculty who can take a substitution.
  final bool availableOnly;

  StaffFilters copyWith({
    String? searchQuery,
    String? department,
    String? designation,
    FacultyStatus? status,
    bool? availableOnly,
    bool clearDepartment = false,
    bool clearDesignation = false,
    bool clearStatus = false,
  }) {
    return StaffFilters(
      searchQuery: searchQuery ?? this.searchQuery,
      department: clearDepartment ? null : (department ?? this.department),
      designation: clearDesignation ? null : (designation ?? this.designation),
      status: clearStatus ? null : (status ?? this.status),
      availableOnly: availableOnly ?? this.availableOnly,
    );
  }

  /// True when nothing is narrowed, so the UI can show a "no matches" hint
  /// that offers a reset.
  bool get isActive =>
      searchQuery.isNotEmpty ||
      department != null ||
      designation != null ||
      status != null ||
      availableOnly;

  static const unfiltered = StaffFilters();
}
