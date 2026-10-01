// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:attendance_system_admin/core/failure.dart';
import 'package:attendance_system_admin/core/usecase.dart';
import 'package:attendance_system_admin/features/students/domain/entities/students_entities.dart';
import 'package:attendance_system_admin/features/students/domain/repositories/students_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Use case that fetches a student's per-day attendance log.
class GetStudentAttendanceLogUsecase
    implements Usecase<List<AttendanceLogDay>, AttendanceLogParams> {
  final StudentsRepository _studentsRepository;

  GetStudentAttendanceLogUsecase({
    required StudentsRepository studentsRepository,
  }) : _studentsRepository = studentsRepository;

  @override
  Future<Either<Failure, List<AttendanceLogDay>>> call(
    AttendanceLogParams params,
  ) {
    return _studentsRepository.getStudentAttendanceLog(params);
  }
}
