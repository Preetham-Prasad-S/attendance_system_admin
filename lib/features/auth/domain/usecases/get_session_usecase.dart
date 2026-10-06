// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:attendance_system_admin/core/entities/user_entity.dart';
import 'package:attendance_system_admin/core/failure.dart';
import 'package:attendance_system_admin/core/usecase.dart';
import 'package:attendance_system_admin/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Use case that resolves the signed-in user's profile.
///
/// Needed on cold start: a persisted session takes the app straight to the
/// shell, so `AuthBloc` never emits `AuthSuccess` and nothing would otherwise
/// know the caller's role or home institute.
class GetSessionUsecase implements Usecase<UserEntity, NoParams> {
  final AuthRepository _authRepository;

  GetSessionUsecase({required AuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, UserEntity>> call(NoParams params) {
    return _authRepository.getCurrentProfile();
  }
}