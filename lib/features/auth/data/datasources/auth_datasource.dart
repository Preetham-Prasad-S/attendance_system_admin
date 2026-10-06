import 'package:attendance_system_admin/core/models/user_model.dart';

abstract interface class AuthDatasource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> signup(UserModel user, String password);
  Future<void> logout();

  /// Reads the caller's own profile row. Used on cold start, where a
  /// persisted session means [AuthBloc] never emits `AuthSuccess`.
  Future<UserModel> fetchCurrentProfile();

  /// Sets the caller's password (first-login setup) and flips their profile
  /// from 'invited' to 'active'. Both steps succeed or neither is reported.
  Future<void> completePasswordSetup(String password);
}
