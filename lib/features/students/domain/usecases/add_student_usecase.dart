// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:attendance_system_admin/core/failure.dart';
import 'package:attendance_system_admin/core/usecase.dart';
import 'package:attendance_system_admin/features/students/domain/entities/students_entities.dart';
import 'package:attendance_system_admin/features/students/domain/repositories/students_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Use case that inserts a new student into the roster.
class AddStudentUsecase implements Usecase<Student, AddStudentParams> {
  final StudentsRepository _studentsRepository;

  AddStudentUsecase({required StudentsRepository studentsRepository})
    : _studentsRepository = studentsRepository;

  @override
  Future<Either<Failure, Student>> call(AddStudentParams params) {
    return _studentsRepository.addStudent(params);
  }
}
