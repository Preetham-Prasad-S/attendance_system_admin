// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:attendance_system_admin/core/failure.dart';
import 'package:attendance_system_admin/core/usecase.dart';
import 'package:attendance_system_admin/features/students/domain/entities/students_entities.dart';
import 'package:attendance_system_admin/features/students/domain/repositories/students_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Use case that fetches one filtered page of directory entries.
class GetStudentsPageUsecase
    implements Usecase<DirectoryPage, DirectoryFilters> {
  final StudentsRepository _studentsRepository;

  GetStudentsPageUsecase({required StudentsRepository studentsRepository})
    : _studentsRepository = studentsRepository;

  @override
  Future<Either<Failure, DirectoryPage>> call(DirectoryFilters params) {
    return _studentsRepository.getStudentsPage(params);
  }
}
