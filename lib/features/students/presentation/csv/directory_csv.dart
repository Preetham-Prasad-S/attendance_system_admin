import '../../domain/entities/students_entities.dart';

/// Builds the "Export Directory" CSV payload from the fetched rows.
abstract final class DirectoryCsv {
  static const headers = [
    'Roll No',
    'Name',
    'Email',
    'Department',
    'Status',
    'Sessions',
    'Present %',
    'Tier',
  ];

  static String build(List<StudentDirectoryEntry> entries) {
    final buffer = StringBuffer();
    buffer.writeln(headers.map(_escape).join(','));
    for (final entry in entries) {
      final student = entry.student;
      final summary = entry.summary;
      final row = [
        student.studentNo,
        student.name,
        student.email ?? '',
        student.department ?? '',
        student.status,
        '${summary.attendedDays}/${summary.requiredDays}',
        summary.requiredDays > 0
            ? summary.presentPct.toStringAsFixed(1)
            : '',
        summary.tier.label,
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
