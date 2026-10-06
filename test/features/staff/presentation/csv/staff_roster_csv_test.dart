import 'package:attendance_system_admin/features/staff/data/mock/staff_mock_data.dart';
import 'package:attendance_system_admin/features/staff/domain/entities/staff_entities.dart';
import 'package:attendance_system_admin/features/staff/presentation/csv/staff_roster_csv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  FacultyProfile member(
    String id, {
    required String name,
    required String designation,
    required String department,
    required FacultyStatus status,
    required bool isHod,
    required bool isFreeBlock,
    required int completed,
    required int total,
    String? availability,
  }) {
    return FacultyProfile(
      id: id,
      name: name,
      designation: designation,
      department: department,
      status: status,
      isHeadOfDepartment: isHod,
      gateIn: 'Gate A In: 08:14 AM',
      currentSession: FacultySession(
        code: isFreeBlock ? 'Faculty Lounge / Cabin' : 'CS-401',
        venue: isFreeBlock ? '' : 'Hall 302',
        slotLabel: '10:00 - 11:30 AM (Slot 2)',
        isFreeBlock: isFreeBlock,
        availabilityLabel: availability,
      ),
      sessionsCompleted: completed,
      sessionsTotal: total,
      syllabusMatchPercent: 96,
    );
  }

  group('StaffRosterCsv.build', () {
    test('emits the header and one row per faculty member', () {
      final csv = StaffRosterCsv.build([
        member(
          'STF-1',
          name: 'Dr. Rajeshwar Rao',
          designation: 'Professor',
          department: 'Computer Science & Engineering',
          status: FacultyStatus.inLecture,
          isHod: true,
          isFreeBlock: false,
          completed: 2,
          total: 4,
        ),
        member(
          'STF-2',
          name: 'Dr. Lin Chen',
          designation: 'Associate Professor',
          department: 'Computer Science & Engineering',
          status: FacultyStatus.available,
          isHod: false,
          isFreeBlock: true,
          completed: 1,
          total: 3,
          availability: 'Research Office CS-109',
        ),
      ]);

      final lines = csv.trim().split('\n');
      expect(lines, hasLength(3));
      expect(
        lines.first,
        'Staff ID,Name,Designation,Department,HOD,Status,Current Session,'
        'Venue / Location,Slot,Gate In,Sessions Completed,Sessions Total,'
        'Syllabus Match %,Substitutable',
      );
      expect(
        lines[1],
        'STF-1,Dr. Rajeshwar Rao,Professor,Computer Science & Engineering,'
        'Yes,In Lecture,CS-401,Hall 302,10:00 - 11:30 AM (Slot 2),'
        'Gate A In: 08:14 AM,2,4,96,No',
      );
      // Free faculty swap the session columns for their parking location.
      expect(
        lines[2],
        'STF-2,Dr. Lin Chen,Associate Professor,'
        'Computer Science & Engineering,No,Available,Free Block,'
        'Research Office CS-109,10:00 - 11:30 AM (Slot 2),Gate A In: 08:14 AM,'
        '1,3,96,Yes',
      );
    });

    test('escapes commas, quotes and newlines', () {
      final csv = StaffRosterCsv.build([
        member(
          'STF-3',
          name: 'Chen, Lin "LC"',
          designation: 'Professor',
          department: 'Civil, Structural',
          status: FacultyStatus.available,
          isHod: false,
          isFreeBlock: true,
          completed: 1,
          total: 1,
          availability: 'Block A',
        ),
      ]);

      final lines = csv.trim().split('\n');
      expect(lines[1], contains('"Chen, Lin ""LC"""'));
      expect(lines[1], contains('"Civil, Structural"'));
    });

    test('writes an empty location when a free block has no note', () {
      final csv = StaffRosterCsv.build([
        member(
          'STF-4',
          name: 'Dr. Anonymous',
          designation: 'Lecturer',
          department: 'Mathematics',
          status: FacultyStatus.available,
          isHod: false,
          isFreeBlock: true,
          completed: 0,
          total: 2,
        ),
      ]);

      expect(csv, contains('Free Block,,10:00 - 11:30 AM (Slot 2)'));
    });

    test('emits only the header for an empty roster', () {
      final csv = StaffRosterCsv.build(const []);
      expect(csv.trim().split('\n'), hasLength(1));
    });

    test('round-trips the whole mock roster without dropping columns', () {
      final csv = StaffRosterCsv.build(StaffMockData.faculty);
      final lines = csv.trim().split('\n');

      expect(lines, hasLength(StaffMockData.faculty.length + 1));
      // Each row is keyed by its staff ID and carries a readable status label.
      for (var i = 0; i < StaffMockData.faculty.length; i++) {
        final profile = StaffMockData.faculty[i];
        expect(lines[i + 1], startsWith('${profile.id},${profile.name},'));
        expect(lines[i + 1], contains(profile.status.label));
      }
    });
  });
}
