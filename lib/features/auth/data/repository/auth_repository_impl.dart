import 'package:attendance_system_admin/core/entities/user_entity.dart';
import 'package:attendance_system_admin/core/auth_failure.dart';
import 'package:attendance_system_admin/features/auth/data/datasources/auth_datasource.dart';
import 'package:attendance_system_admin/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDatasource _authDatasource;

  AuthRepositoryImpl({required AuthDatasource authDatasource})
    : _authDatasource = authDatasource;

  @override
  Future<Either<AuthFailure, UserEntity>> signup(
    UserEntity user,
    String password,
  ) async {
    try {
      final model = await _authDatasource.signup(user.toModel(), password);
      return Right(UserEntity.fromModel(model));
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }
}
