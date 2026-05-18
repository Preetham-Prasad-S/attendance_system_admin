import 'package:attendance_system_admin/features/auth/data/datasource/auth_datasource.dart';
import 'package:fpdart/fpdart.dart';

class AuthDatasourceImpl implements AuthDatasource {
  @override
  Future<Either<String, String>> login(String email, String password) {
    // TODO: Implement login function in authdatasource
    throw UnimplementedError();
  }

  @override
  Future<Either<String, String>> signup(String email, String password) {
    // TODO: implement signup
    throw UnimplementedError();
  }
}
