import 'package:fpdart/fpdart.dart';

abstract interface class AuthDatasource {
  Future<Either<String, String>> login(String email, String password);
}
