// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:attendance_system_admin/core/failure.dart';
import 'package:attendance_system_admin/core/usecase.dart';
import 'package:attendance_system_admin/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Use case for signing the current user out.
class LogoutUsecase implements Usecase<Unit, NoParams> {
  final AuthRepository _authRepository;

  LogoutUsecase({required AuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, Unit>> call(NoParams params) {
    return _authRepository.logout();
  }
}
