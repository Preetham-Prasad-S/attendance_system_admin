import 'package:attendance_system_admin/features/students/domain/entities/students_entities.dart';
import 'package:attendance_system_admin/features/students/presentation/csv/directory_csv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  StudentDirectoryEntry entry({
    required String name,
    required String studentNo,
    String? email,
    String? department,
  }) {
    return StudentDirectoryEntry(
      student: Student(
        id: 'id-$studentNo',
        studentNo: studentNo,
        name: name,
        email: email,
        department: department,
        status: 'active',
        createdAt: DateTime(2026, 1, 1),
      ),
      summary: const AttendanceSummary(
        recordsTotal: 30,
        presentDays: 27,
        lateDays: 1,
        absentDays: 2,
        leaveDays: 0,
      ),
      lastMethod: 'biometric',
      lastRecordedAt: DateTime(2026, 10, 1, 8, 42),
    );
  }

  group('DirectoryCsv.build', () {
    test('emits the header and one row per entry', () {
      final csv = DirectoryCsv.build([
        entry(
          name: 'Aarav Patel',
          studentNo: 'CS2021-042',
          email: 'a.patel@apex.edu',
          department: 'Computer Science',
        ),
        entry(
          name: 'Rohan Sharma',
          studentNo: 'ME2022-019',
          department: 'Mechanical',
        ),
      ]);

      final lines = csv.trim().split('\n');
      expect(lines, hasLength(3));
      expect(
        lines.first,
        'Roll No,Name,Email,Department,Status,Sessions,Present %,Tier',
      );
      expect(
        lines[1],
        'CS2021-042,Aarav Patel,a.patel@apex.edu,Computer Science,active,'
        '28/30,93.3,Excellent',
      );
      // Missing email becomes an empty field.
      expect(
        lines[2],
        'ME2022-019,Rohan Sharma,,Mechanical,active,28/30,93.3,Excellent',
      );
    });

    test('escapes commas, quotes and newlines', () {
      final csv = DirectoryCsv.build([
        entry(name: 'Patel, Aarav "AP"', studentNo: 'CS 1'),
      ]);

      final lines = csv.trim().split('\n');
      expect(
        lines[1],
        'CS 1,"Patel, Aarav ""AP""",,,active,28/30,93.3,Excellent',
      );
    });

    test('uses an empty percentage when there are no required sessions', () {
      final noSessions = StudentDirectoryEntry(
        student: Student(
          id: 's1',
          studentNo: 'NEW-001',
          name: 'New Student',
          email: null,
          department: null,
          status: 'active',
          createdAt: DateTime(2026, 10, 1),
        ),
        summary: const AttendanceSummary(
          recordsTotal: 0,
          presentDays: 0,
          lateDays: 0,
          absentDays: 0,
          leaveDays: 0,
        ),
        lastMethod: null,
        lastRecordedAt: null,
      );

      final csv = DirectoryCsv.build([noSessions]);

      expect(csv, contains('NEW-001,New Student,,,active,0/0,,No data'));
    });
  });
}
