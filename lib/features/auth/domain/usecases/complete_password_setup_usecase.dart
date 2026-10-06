// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:attendance_system_admin/core/failure.dart';
import 'package:attendance_system_admin/core/usecase.dart';
import 'package:attendance_system_admin/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Use case for an invited account's first-login password setup.
class CompletePasswordSetupUsecase implements Usecase<Unit, String> {
  final AuthRepository _authRepository;

  CompletePasswordSetupUsecase({required AuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, Unit>> call(String password) {
    return _authRepository.completePasswordSetup(password);
  }
}