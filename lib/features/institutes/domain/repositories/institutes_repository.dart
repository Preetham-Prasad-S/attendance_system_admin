import 'package:attendance_system_admin/core/failure.dart';
import 'package:attendance_system_admin/features/institutes/domain/entities/institute_entity.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class InstitutesRepository {
  Future<Either<Failure, List<Institute>>> getInstitutes();

  Future<Either<Failure, Institute>> createInstitute(
    CreateInstituteParams params,
  );

  Future<Either<Failure, Institute>> updateInstitute(
    String slug,
    UpdateInstituteParams params,
  );

  Future<Either<Failure, List<InstituteAdmin>>> getInstituteAdmins(String slug);

  Future<Either<Failure, Unit>> assignAdminToInstitute({
    required String profileId,
    required String slug,
  });

  Future<Either<Failure, InviteAdminResult>> inviteAdmin(
    InviteAdminParams params,
  );
}