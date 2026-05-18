import 'package:attendance_system_admin/features/auth/data/datasource/auth_datasource.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthDatasourceImpl implements AuthDatasource {
  final SupabaseClient _supabaseClient;

  AuthDatasourceImpl({required SupabaseClient supabaseClient})
    : _supabaseClient = supabaseClient;

  @override
  Future<String> login(String email, String password) async {
    final result = await _supabaseClient.auth.signInWithPassword(
      password: password,
      email: email,
    );

    final user = result.user;

    if (user != null) {
      return user.id;
    }

    return "No user found";
  }

  @override
  Future<String> signup(String email, String password) {
    // TODO: implement signup
    throw UnimplementedError();
  }
}
