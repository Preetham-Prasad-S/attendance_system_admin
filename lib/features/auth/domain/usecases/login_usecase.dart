// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:attendance_system_admin/core/entities/user_entity.dart';
import 'package:attendance_system_admin/core/failure.dart';
import 'package:attendance_system_admin/core/usecase.dart';
import 'package:attendance_system_admin/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Use case for logging in an existing user.
class LoginUsecase implements Usecase<UserEntity, LoginUsecaseParams> {
  final AuthRepository _authRepository;

  LoginUsecase({required AuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, UserEntity>> call(LoginUsecaseParams params) {
    return _authRepository.login(params.email, params.password);
  }
}

/// Parameters required for the login use case.
class LoginUsecaseParams {
  final String email;
  final String password;

  LoginUsecaseParams({required this.email, required this.password});
}
