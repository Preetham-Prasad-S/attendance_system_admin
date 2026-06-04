import 'package:attendance_system_admin/features/auth/data/models/user_model.dart';

abstract interface class AuthDatasource {
  Future<UserModel?> login(String email, String password);
  Future<UserModel?> signup(UserModel user, String password);
}
