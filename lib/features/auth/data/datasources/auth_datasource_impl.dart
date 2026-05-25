import 'package:attendance_system_admin/features/auth/data/datasources/auth_datasource.dart';
import 'package:attendance_system_admin/features/auth/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthDatasourceImpl implements AuthDatasource {
  final SupabaseClient _supabaseClient;

  AuthDatasourceImpl({required SupabaseClient supabaseClient})
    : _supabaseClient = supabaseClient;

  @override
  Future<UserModel?> login(String email, String password) {
    // TODO: implement login
    throw UnimplementedError();
  }

  @override
  Future<UserModel?> signup(String email, String password) {
    // TODO: implement signup
    throw UnimplementedError();
  }
}
