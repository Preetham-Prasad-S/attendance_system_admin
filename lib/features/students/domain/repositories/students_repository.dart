import 'package:attendance_system_admin/core/failure.dart';
import 'package:attendance_system_admin/features/students/domain/entities/students_entities.dart';
import 'package:fpdart/fpdart.dart';

/// Data contract for the student directory.
abstract interface class StudentsRepository {
  /// Directory KPI cards + department filter options.
  Future<Either<Failure, DirectoryKpis>> getDirectoryKpis();

  /// One filtered/paginated page of directory entries.
  Future<Either<Failure, DirectoryPage>> getStudentsPage(
    DirectoryFilters filters,
  );

  /// Per-day attendance log for one student over [params.days] days.
  Future<Either<Failure, List<AttendanceLogDay>>> getStudentAttendanceLog(
    AttendanceLogParams params,
  );

  /// Inserts a new student and returns the created row.
  Future<Either<Failure, Student>> addStudent(AddStudentParams params);
}
