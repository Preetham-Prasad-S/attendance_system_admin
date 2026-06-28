import 'package:attendance_system_admin/features/auth/data/datasources/auth_datasource.dart';
import 'package:attendance_system_admin/core/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthDatasourceImpl implements AuthDatasource {
  final SupabaseClient _supabaseClient;

  AuthDatasourceImpl({required SupabaseClient supabaseClient})
    : _supabaseClient = supabaseClient;

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final request = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final response = request.user;

      if (response != null) {
        final data = await _supabaseClient
            .from("User")
            .select()
            .eq("id", response.id)
            .single();

        return UserModel.fromMap(data);
      }

      throw AuthException("Login Failed --> AuthDatasource.login()");
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException(
        "AuthException : ${e.toString()} --> AuthDatasource.login()",
      );
    }
  }

  @override
  Future<UserModel> signup(UserModel user, String password) async {
    try {
      final request = await _supabaseClient.auth.signUp(
        email: user.email,
        password: password,
        data: {
          "name": user.name,
          "department": user.department,
          "phoneNo": user.phoneNo,
          "userRole": user.userRole,
          "organization": user.organization,
        },
      );

      final response = request.user;

      if (response != null) {
        final createdUser = user.copyWith(id: response.id);

        return createdUser;
      }

      throw AuthException("Sign In Failed --> AuthDatasource.signup()");
    } on AuthException {
      rethrow; // don't double-wrap AuthExceptions
    } catch (e) {
      throw AuthException(
        "AuthException : ${e.toString()} --> AuthDatasource.signup()",
      );
    }
  }
}
