import 'package:attendance_system_admin/features/students/domain/entities/students_entities.dart';

/// Remote data contract for the student directory queries.
abstract interface class StudentsDatasource {
  /// Aggregates the directory KPI cards over the compliance window and
  /// resolves the department filter options.
  Future<DirectoryKpis> fetchDirectoryKpis();

  /// Fetches one filtered/paginated page of directory entries.
  Future<DirectoryPage> fetchStudentsPage(DirectoryFilters filters);

  /// Fetches the per-day attendance log for one student.
  Future<List<AttendanceLogDay>> fetchAttendanceLog(
    String studentId,
    int days,
  );

  /// Inserts a new student and returns the created row.
  Future<Student> addStudent(AddStudentParams params);
}
