import 'package:attendance_system_admin/features/institutes/data/datasources/institutes_datasource.dart';
import 'package:attendance_system_admin/features/institutes/domain/entities/institute_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InstitutesDatasourceImpl implements InstitutesDatasource {
  final SupabaseClient _supabaseClient;

  InstitutesDatasourceImpl({required SupabaseClient supabaseClient})
    : _supabaseClient = supabaseClient;

  static const List<String> _instituteColumns = [
    'id',
    'slug',
    'name',
    'code',
    'is_active',
  ];

  /// Lowercase, hyphenated, trimmed — the form used as `organization`.
  static String slugify(String value) => slugifyInstituteName(value);

  static String? _nullIfEmpty(String? value) {
    final trimmed = value?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }

  @override
  Future<List<Institute>> fetchInstitutes() async {
    final rows = await _supabaseClient
        .from('institutes')
        .select(_instituteColumns.join(','))
        .order('name');
    return rows.map(Institute.fromMap).toList(growable: false);
  }

  @override
  Future<Institute> createInstitute(CreateInstituteParams params) async {
    final name = params.name.trim();
    final slug = slugify(name);
    if (slug.isEmpty) {
      throw Exception('Enter a name for the institute.');
    }

    try {
      final row = await _supabaseClient
          .from('institutes')
          .insert(<String, dynamic>{
            'slug': slug,
            'name': name,
            'code': _nullIfEmpty(params.code),
          })
          .select(_instituteColumns.join(','))
          .single();
      return Institute.fromMap(row);
    } on PostgrestException catch (error) {
      if (error.code == '23505') {
        throw Exception('An institute named "$name" already exists.');
      }
      rethrow;
    }
  }

  @override
  Future<Institute> updateInstitute(
    String slug,
    UpdateInstituteParams params,
  ) async {
    final changes = <String, dynamic>{};
    final name = _nullIfEmpty(params.name);
    if (name != null) changes['name'] = name;
    final code = _nullIfEmpty(params.code);
    if (code != null) changes['code'] = code;
    if (params.isActive != null) changes['is_active'] = params.isActive;

    if (changes.isEmpty) {
      throw Exception('There is nothing to update.');
    }

    final row = await _supabaseClient
        .from('institutes')
        .update(changes)
        .eq('slug', slug)
        .select(_instituteColumns.join(','))
        .single();
    return Institute.fromMap(row);
  }

  @override
  Future<List<InstituteAdmin>> fetchInstituteAdmins(String slug) async {
    final rows = await _supabaseClient
        .from('profiles')
        .select('id, email, name, status')
        .eq('organization', slug)
        .order('name');
    return rows.map(InstituteAdmin.fromMap).toList(growable: false);
  }

  @override
  Future<void> assignAdminToInstitute({
    required String profileId,
    required String slug,
  }) async {
    final rows = await _supabaseClient
        .from('profiles')
        .update(<String, dynamic>{'organization': slug})
        .eq('id', profileId)
        .select('id');

    if (rows.isEmpty) {
      throw Exception('That account could not be moved. Only super admins can do this.');
    }
  }

  @override
  Future<InviteAdminResult> inviteAdmin(InviteAdminParams params) async {
    final email = params.email.trim();
    if (email.isEmpty || !email.contains('@')) {
      throw Exception('Enter a valid email address.');
    }

    // Server-side: creating an auth.users row requires the service_role key,
    // so the Edge Function performs it and stamps `organization` itself.
    final response = await _supabaseClient.functions.invoke(
      'create-institute-admin',
      body: <String, dynamic>{
        'name': params.name.trim(),
        'email': email,
        'institute_slug': params.instituteSlug,
      },
    );

    if (response.status != 200) {
      throw Exception(_errorMessageFrom(response.data));
    }

    final data = response.data as Map<String, dynamic>;
    return InviteAdminResult(
      profileId: data['profile_id'] as String,
      setupLink: data['setup_link'] as String?,
    );
  }

  /// Surfaces the function's `{ error }` body, falling back to a generic
  /// message so the UI never shows a raw status code.
  static String _errorMessageFrom(Object? data) {
    if (data is Map && data['error'] is String) {
      final message = (data['error']! as String).trim();
      if (message.isNotEmpty) return message;
    }
    return 'Could not create the admin account. Please try again.';
  }
}