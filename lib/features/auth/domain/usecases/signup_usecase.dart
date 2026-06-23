// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:attendance_system_admin/core/entities/user_entity.dart';
import 'package:attendance_system_admin/core/failure.dart';
import 'package:attendance_system_admin/core/usecase.dart';
import 'package:attendance_system_admin/features/auth/domain/entities/signup_user_entity.dart';
import 'package:attendance_system_admin/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Use case for signing up a new user.
class SignupUsecase implements Usecase<UserEntity, SignupUsecaseParams> {
  final AuthRepository _authRepository;

  SignupUsecase({required AuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, UserEntity>> call(SignupUsecaseParams params) {
    return _authRepository.signup(params.signUpUserEntity);
  }
}

/// Parameters required for the signup use case.
class SignupUsecaseParams {
  final SignUpUserEntity signUpUserEntity;

  SignupUsecaseParams({required this.signUpUserEntity});
}
