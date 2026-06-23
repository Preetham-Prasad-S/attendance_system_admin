import 'package:attendance_system_admin/features/auth/data/datasources/auth_datasource.dart';
import 'package:attendance_system_admin/features/auth/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthDatasourceImpl implements AuthDatasource {
  final SupabaseClient _supabaseClient;

  AuthDatasourceImpl({required SupabaseClient supabaseClient})
    : _supabaseClient = supabaseClient;

  @override
  Future<UserModel> login(String email, String password) async {
    // TODO: implement signup
    throw UnimplementedError();
  }

  @override
  Future<UserModel> signup(UserModel user, String password) async {
    try {
      final request = await _supabaseClient.auth.signUp(
        email: user.email,
        password: password,
      );

      final response = request.user;

      if (response != null) {
        return UserModel(
          id: response.id,
          email: user.email,
          name: user.name,
          department: user.department,
          phoneNo: user.phoneNo,
          userRole: user.userRole,
          organization: user.organization,
        );
      }

      throw AuthException("User is null --> AuthDatasource.signup()");
    } on AuthException {
      rethrow; // don't double-wrap AuthExceptions
    } catch (e) {
      throw AuthException(
        "AuthException : ${e.toString()} --> AuthDatasource.signup()",
      );
    }
  }
}
