import 'package:attendance_system_admin/features/profile/data/datasource/profile_datasource.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileDatasourceImpl implements ProfileDatasource {
  final SupabaseClient _client;

  ProfileDatasourceImpl({required SupabaseClient client}) : _client = client;

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
