import 'package:attendance_system_admin/features/staff/domain/entities/staff_entities.dart';

/// Builds the "Export Roster" CSV payload from the currently filtered rows.
///
/// Mirrors `DirectoryCsv` in the students feature so both exports behave the
/// same way.
abstract final class StaffRosterCsv {
  static const headers = [
    'Staff ID',
    'Name',
    'Designation',
    'Department',
    'HOD',
    'Status',
    'Current Session',
    'Venue / Location',
    'Slot',
    'Gate In',
    'Sessions Completed',
    'Sessions Total',
    'Syllabus Match %',
    'Substitutable',
  ];

  static String build(List<FacultyProfile> faculty) {
    final buffer = StringBuffer();
    buffer.writeln(headers.map(_escape).join(','));
    for (final member in faculty) {
      final session = member.currentSession;
      final row = [
        member.id,
        member.name,
        member.designation,
        member.department,
        member.isHeadOfDepartment ? 'Yes' : 'No',
        member.status.label,
        session.isFreeBlock ? 'Free Block' : session.code,
        session.isFreeBlock ? (session.availabilityLabel ?? '') : session.venue,
        session.slotLabel,
        member.gateIn,
        '${member.sessionsCompleted}',
        '${member.sessionsTotal}',
        '${member.syllabusMatchPercent}',
        member.isSubstitutable ? 'Yes' : 'No',
      ];
      buffer.writeln(row.map(_escape).join(','));
    }
    return buffer.toString();
  }

  static String _escape(String field) {
    final needsQuotes = RegExp(r'[",\n\r]').hasMatch(field);
    if (!needsQuotes) return field;
    return '"${field.replaceAll('"', '""')}"';
  }
}
