import 'package:attendance_system_admin/core/entities/user_entity.dart';
import 'package:attendance_system_admin/core/failure.dart';
import 'package:attendance_system_admin/features/auth/domain/entities/signup_user_entity.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, UserEntity>> signup(SignUpUserEntity user);
  Future<Either<Failure, UserEntity>> login(String email, String password);
  Future<Either<Failure, Unit>> logout();

  /// The signed-in user's own profile, including `role`, `organization` and
  /// the invited/active status.
  Future<Either<Failure, UserEntity>> getCurrentProfile();

  /// First-login password setup for an invited account.
  Future<Either<Failure, Unit>> completePasswordSetup(String password);
}
