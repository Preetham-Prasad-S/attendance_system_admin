// ignore_for_file: public_member_api_docs

import 'package:attendance_system_admin/features/staff/domain/entities/staff_entities.dart';
import 'package:flutter/material.dart';

/// Static fixture backing the Faculty Workload & Lecture Coverage screen.
///
/// Mirrors `ui_references/staff_screen.png`. There is no Supabase source for
/// this data yet: `public.staff` (migration `0002_core_domain.sql`) carries
/// only `name`, `email`, `department`, and `staff_type`, with no availability,
/// gate-in, session, or coverage columns. Swapping this out for a real
/// `StaffDatasource` later requires no presentation-layer change — every
/// widget consumes the entities in
/// `features/staff/domain/entities/staff_entities.dart`.
///
/// Values are `const` so the whole screen renders without a loading state.
/// Replaced wholesale once the staffing tables land.
abstract final class StaffMockData {
  static const kpis = StaffKpis(
    facultyOnDuty: 156,
    checkedIn: 147,
    totalOnRoster: 156,
    attendanceTrendPercent: 94.2,
    conductedToday: 142,
    scheduledToday: 158,
    inFlight: 12,
    remaining: 16,
    freeNow: 24,
    onCampus: 18,
    pendingSubstitutes: 4,
    highPrioritySubstitutes: 2,
  );

  static const faculty = <FacultyProfile>[
    FacultyProfile(
      id: 'STF-1042',
      name: 'Dr. Rajeshwar Rao',
      designation: 'Professor',
      department: 'Computer Science & Engineering',
      status: FacultyStatus.inLecture,
      isHeadOfDepartment: true,
      gateIn: 'Gate A In: 08:14 AM',
      currentSession: FacultySession(
        code: 'CS-401',
        venue: 'Hall 302',
        slotLabel: '10:00 - 11:30 AM (Slot 2)',
        isFreeBlock: false,
      ),
      sessionsCompleted: 2,
      sessionsTotal: 4,
      syllabusMatchPercent: 96,
    ),
    FacultyProfile(
      id: 'STF-1078',
      name: 'Dr. Lin Chen',
      designation: 'Associate Professor',
      department: 'Computer Science & Engineering',
      status: FacultyStatus.available,
      isHeadOfDepartment: false,
      gateIn: 'Gate B In: 08:42 AM',
      currentSession: FacultySession(
        code: 'Faculty Lounge / Cabin',
        venue: '',
        slotLabel: 'Free Slot (10:00 - 12:30)',
        isFreeBlock: true,
        availabilityLabel: 'Research Office CS-109',
      ),
      sessionsCompleted: 1,
      sessionsTotal: 3,
      syllabusMatchPercent: 98,
    ),
    FacultyProfile(
      id: 'STF-1103',
      name: 'Prof. Sarah Jenkins',
      designation: 'Professor',
      department: 'Civil Engineering',
      status: FacultyStatus.inLecture,
      isHeadOfDepartment: false,
      gateIn: 'Gate A In: 09:02 AM',
      currentSession: FacultySession(
        code: 'CE-304',
        venue: 'Hall 104',
        slotLabel: '10:00 - 11:30 AM (Slot 2)',
        isFreeBlock: false,
      ),
      sessionsCompleted: 2,
      sessionsTotal: 5,
      syllabusMatchPercent: 71,
    ),
    FacultyProfile(
      id: 'STF-1119',
      name: 'Dr. Meera Nambiar',
      designation: 'Assistant Professor',
      department: 'Computer Science & Engineering',
      status: FacultyStatus.available,
      isHeadOfDepartment: false,
      gateIn: 'Gate B In: 08:55 AM',
      currentSession: FacultySession(
        code: 'Faculty Lounge / Cabin',
        venue: '',
        slotLabel: 'Free Slot (10:00 - 12:30)',
        isFreeBlock: true,
        availabilityLabel: 'Free in Faculty Block C',
      ),
      sessionsCompleted: 3,
      sessionsTotal: 4,
      syllabusMatchPercent: 98,
    ),
    FacultyProfile(
      id: 'STF-1126',
      name: 'Prof. Marcus Sterling',
      designation: 'Professor',
      department: 'Computer Science & Engineering',
      status: FacultyStatus.onLeave,
      isHeadOfDepartment: false,
      gateIn: 'Gate A In: 07:55 AM',
      currentSession: FacultySession(
        code: 'CS-302',
        venue: 'Auditorium B',
        slotLabel: '11:30 - 01:00 PM (Slot 3)',
        isFreeBlock: false,
      ),
      sessionsCompleted: 1,
      sessionsTotal: 4,
      syllabusMatchPercent: 88,
    ),
    FacultyProfile(
      id: 'STF-1144',
      name: 'Dr. Nathan Drake',
      designation: 'Associate Professor',
      department: 'Electronics & Communication',
      status: FacultyStatus.onLeave,
      isHeadOfDepartment: false,
      gateIn: 'Gate C In: 08:05 AM',
      currentSession: FacultySession(
        code: 'EC-210',
        venue: 'Lab 2',
        slotLabel: '02:00 - 03:30 PM (Slot 5)',
        isFreeBlock: false,
      ),
      sessionsCompleted: 0,
      sessionsTotal: 3,
      syllabusMatchPercent: 79,
    ),
    FacultyProfile(
      id: 'STF-1157',
      name: 'Prof. Elena Rostov',
      designation: 'Professor',
      department: 'Mathematics & Applied Sciences',
      status: FacultyStatus.available,
      isHeadOfDepartment: false,
      gateIn: 'Gate B In: 09:11 AM',
      currentSession: FacultySession(
        code: 'Faculty Lounge / Cabin',
        venue: '',
        slotLabel: 'Free Slot (11:00 - 01:00)',
        isFreeBlock: true,
        availabilityLabel: 'Faculty Block A, Cabin 4',
      ),
      sessionsCompleted: 2,
      sessionsTotal: 3,
      syllabusMatchPercent: 84,
    ),
    FacultyProfile(
      id: 'STF-1161',
      name: 'Dr. Vikram Singh',
      designation: 'Professor',
      department: 'Mechanical Engineering',
      status: FacultyStatus.inLecture,
      isHeadOfDepartment: true,
      gateIn: 'Gate A In: 08:02 AM',
      currentSession: FacultySession(
        code: 'ME-215',
        venue: 'Hall 208',
        slotLabel: '10:00 - 11:30 AM (Slot 2)',
        isFreeBlock: false,
      ),
      sessionsCompleted: 3,
      sessionsTotal: 4,
      syllabusMatchPercent: 91,
    ),
    FacultyProfile(
      id: 'STF-1175',
      name: 'Dr. Neha Gupta',
      designation: 'Assistant Professor',
      department: 'Electronics & Communication',
      status: FacultyStatus.available,
      isHeadOfDepartment: false,
      gateIn: 'Gate C In: 08:38 AM',
      currentSession: FacultySession(
        code: 'Faculty Lounge / Cabin',
        venue: '',
        slotLabel: 'Free Slot (10:00 - 12:30)',
        isFreeBlock: true,
        availabilityLabel: 'Research Lab E-204',
      ),
      sessionsCompleted: 2,
      sessionsTotal: 5,
      syllabusMatchPercent: 90,
    ),
    FacultyProfile(
      id: 'STF-1188',
      name: 'Dr. Sunita Kapoor',
      designation: 'Associate Professor',
      department: 'Civil Engineering',
      status: FacultyStatus.inLecture,
      isHeadOfDepartment: false,
      gateIn: 'Gate A In: 08:26 AM',
      currentSession: FacultySession(
        code: 'CE-118',
        venue: 'Hall 107',
        slotLabel: '12:00 - 01:30 PM (Slot 4)',
        isFreeBlock: false,
      ),
      sessionsCompleted: 1,
      sessionsTotal: 4,
      syllabusMatchPercent: 82,
    ),
  ];

  static const coverageAlerts = <CoverageAlert>[
    CoverageAlert(
      id: 'ALERT-CE304',
      severity: AlertSeverity.critical,
      badgeLabel: 'UNATTENDED NOW',
      countdownLabel: '',
      timeRange: '10:00 - 11:30 AM',
      courseCode: 'CE-304',
      courseTitle: 'Structural Analysis',
      venueLine: 'Hall 104 • 64 Students Checked In via Biometrics',
      stage: CoverageStage.recommended,
      noticeIcon: Icons.warning_amber_rounded,
      noticeLead: 'Prof. Sarah Jenkins',
      noticeBody: 'Inbound delay (+38m traffic)',
      substituteName: 'Dr. Meera Nambiar',
      substituteMeta: 'Free in Faculty Block C',
      substituteMatchPercent: 98,
    ),
    CoverageAlert(
      id: 'ALERT-CS302',
      severity: AlertSeverity.warning,
      badgeLabel: 'UPCOMING',
      countdownLabel: '(IN 45M)',
      timeRange: '11:30 - 01:00 PM',
      courseCode: 'CS-302',
      courseTitle: 'Algorithms & Complexity',
      venueLine: 'Auditorium B • 112 Enrolled Students',
      stage: CoverageStage.assigned,
      noticeIcon: Icons.calendar_month_outlined,
      noticeLead: 'Prof. Marcus Sterling',
      noticeBody: 'Approved Duty Leave',
      substituteName: 'Dr. Lin Chen',
      substituteMeta: 'Notified 09:30 AM',
      substituteAcceptedSms: true,
    ),
  ];

  static const leaveApprovals = <LeaveApprovalStub>[
    LeaveApprovalStub(
      id: 'LEAVE-1',
      facultyName: 'Dr. Nathan Drake',
      reasonLine: 'Medical • 2 Days (Nov 14-15)',
      coverageLine: 'Classes covered by Dr. Rao',
    ),
    LeaveApprovalStub(
      id: 'LEAVE-2',
      facultyName: 'Prof. Elena Rostov',
      reasonLine: 'OD: IEEE Conference • 1 Day',
      coverageLine: '1 Lab Pending Assignment',
      isCoverageWarning: true,
    ),
  ];

  /// Total pending leave requests, shown by the rail's "view all (n)" link.
  static const totalLeaveApprovals = 7;

  /// Number of alerts needing immediate action; the rail's "N Urgent" badge.
  static int get urgentAlertCount =>
      coverageAlerts.where((a) => a.severity == AlertSeverity.critical).length;

  static List<String> get departments {
    final seen = <String>{};
    for (final member in faculty) {
      seen.add(member.department);
    }
    final sorted = seen.toList()..sort();
    return sorted;
  }

  static List<String> get designations {
    final seen = <String>{};
    for (final member in faculty) {
      seen.add(member.designation);
    }
    final sorted = seen.toList()..sort();
    return sorted;
  }

  /// Faculty currently able to take a substitution, best match first.
  static List<FacultyProfile> get substitutes {
    final eligible = faculty.where((member) => member.isSubstitutable).toList()
      ..sort(
        (a, b) => b.syllabusMatchPercent.compareTo(a.syllabusMatchPercent),
      );
    return eligible;
  }
}
