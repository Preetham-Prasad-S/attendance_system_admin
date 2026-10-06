import 'package:attendance_system_admin/features/institutes/domain/entities/institute_entity.dart';

abstract interface class InstitutesDatasource {
  /// All institutes in the registry, active first then alphabetical.
  Future<List<Institute>> fetchInstitutes();

  Future<Institute> createInstitute(CreateInstituteParams params);

  Future<Institute> updateInstitute(
    String slug,
    UpdateInstituteParams params,
  );

  /// Accounts belonging to [slug]. Only a super_admin can read these rows.
  Future<List<InstituteAdmin>> fetchInstituteAdmins(String slug);

  /// Moves an existing account into [slug] (`profiles.organization`).
  Future<void> assignAdminToInstitute({
    required String profileId,
    required String slug,
  });

  /// Creates a pending admin account for an institute. Server-side: requires
  /// the `create-institute-admin` Edge Function because creating an
  /// `auth.users` row needs the service_role key.
  Future<InviteAdminResult> inviteAdmin(InviteAdminParams params);
}