import 'package:fpdart/fpdart.dart';

abstract interface class AuthDatasource {
  Future<String> login(String email, String password);
  Future<String> signup(String email, String password);
}
