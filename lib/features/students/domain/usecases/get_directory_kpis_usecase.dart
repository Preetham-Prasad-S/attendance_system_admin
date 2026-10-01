// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:attendance_system_admin/core/failure.dart';
import 'package:attendance_system_admin/core/usecase.dart';
import 'package:attendance_system_admin/features/students/domain/entities/students_entities.dart';
import 'package:attendance_system_admin/features/students/domain/repositories/students_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Use case that fetches the directory KPI cards and department options.
class GetDirectoryKpisUsecase
    implements Usecase<DirectoryKpis, NoParams> {
  final StudentsRepository _studentsRepository;

  GetDirectoryKpisUsecase({required StudentsRepository studentsRepository})
    : _studentsRepository = studentsRepository;

  @override
  Future<Either<Failure, DirectoryKpis>> call(NoParams params) {
    return _studentsRepository.getDirectoryKpis();
  }
}
