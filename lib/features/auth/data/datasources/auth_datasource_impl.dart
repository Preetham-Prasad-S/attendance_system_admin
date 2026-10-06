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
            .from("profiles")
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
          "phone_no": user.phoneNo,
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

  @override
  Future<void> logout() async {
    await _supabaseClient.auth.signOut();
  }

  @override
  Future<UserModel> fetchCurrentProfile() async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) {
      throw AuthException(
        'Not signed in --> AuthDatasource.fetchCurrentProfile()',
      );
    }

    try {
      final data = await _supabaseClient
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();
      return UserModel.fromMap(data);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException(
        "AuthException : ${e.toString()} --> AuthDatasource.fetchCurrentProfile()",
      );
    }
  }

  @override
  Future<void> completePasswordSetup(String password) async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) {
      throw AuthException(
        'Not signed in --> AuthDatasource.completePasswordSetup()',
      );
    }

    try {
      await _supabaseClient.auth.updateUser(
        UserAttributes(password: password),
      );
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException(
        "AuthException : ${e.toString()} --> AuthDatasource.completePasswordSetup()",
      );
    }

    // Only once the password exists does the account become usable.
    // profiles_update_own permits this, and protect_profile_privileges only
    // guards role/organization/id.
    final updated = await _supabaseClient
        .from('profiles')
        .update(<String, dynamic>{'status': 'active'})
        .eq('id', user.id)
        .select('id');

    if (updated.isEmpty) {
      throw AuthException(
        'Could not activate the account --> AuthDatasource.completePasswordSetup()',
      );
    }
  }
}
