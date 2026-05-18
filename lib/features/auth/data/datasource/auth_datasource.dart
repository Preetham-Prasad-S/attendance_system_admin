import 'package:fpdart/fpdart.dart';

abstract interface class AuthDatasource {
  Future<Either<String, String>> login(String email, String password);
  Future<Either<String, String>> signup(String email, String password);
}
