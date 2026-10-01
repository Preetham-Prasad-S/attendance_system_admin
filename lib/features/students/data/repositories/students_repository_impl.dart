import 'package:attendance_system_admin/core/failure.dart';
import 'package:attendance_system_admin/features/students/data/datasources/students_datasource.dart';
import 'package:attendance_system_admin/features/students/domain/entities/students_entities.dart';
import 'package:attendance_system_admin/features/students/domain/repositories/students_repository.dart';
import 'package:fpdart/fpdart.dart';

class StudentsRepositoryImpl implements StudentsRepository {
  final StudentsDatasource _studentsDatasource;

  StudentsRepositoryImpl({required StudentsDatasource studentsDatasource})
    : _studentsDatasource = studentsDatasource;

  @override
  Future<Either<Failure, DirectoryKpis>> getDirectoryKpis() async {
    try {
      return Right(await _studentsDatasource.fetchDirectoryKpis());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, DirectoryPage>> getStudentsPage(
    DirectoryFilters filters,
  ) async {
    try {
      return Right(await _studentsDatasource.fetchStudentsPage(filters));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AttendanceLogDay>>> getStudentAttendanceLog(
    AttendanceLogParams params,
  ) async {
    try {
      return Right(
        await _studentsDatasource.fetchAttendanceLog(
          params.studentId,
          params.days,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Student>> addStudent(AddStudentParams params) async {
    try {
      return Right(await _studentsDatasource.addStudent(params));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
