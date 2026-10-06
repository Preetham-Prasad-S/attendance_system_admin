// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:attendance_system_admin/core/failure.dart';
import 'package:attendance_system_admin/core/usecase.dart';
import 'package:attendance_system_admin/features/institutes/domain/entities/institute_entity.dart';
import 'package:attendance_system_admin/features/institutes/domain/repositories/institutes_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Use case that lists the institutes in the registry.
class GetInstitutesUsecase
    implements Usecase<List<Institute>, NoParams> {
  final InstitutesRepository _institutesRepository;

  GetInstitutesUsecase({required InstitutesRepository institutesRepository})
    : _institutesRepository = institutesRepository;

  @override
  Future<Either<Failure, List<Institute>>> call(NoParams params) {
    return _institutesRepository.getInstitutes();
  }
}

/// Use case that registers a new institute.
class CreateInstituteUsecase
    implements Usecase<Institute, CreateInstituteParams> {
  final InstitutesRepository _institutesRepository;

  CreateInstituteUsecase({required InstitutesRepository institutesRepository})
    : _institutesRepository = institutesRepository;

  @override
  Future<Either<Failure, Institute>> call(CreateInstituteParams params) {
    return _institutesRepository.createInstitute(params);
  }
}

/// Use case that edits an institute's details or deactivates it.
class UpdateInstituteUsecase
    implements Usecase<Institute, UpdateInstituteRequest> {
  final InstitutesRepository _institutesRepository;

  UpdateInstituteUsecase({required InstitutesRepository institutesRepository})
    : _institutesRepository = institutesRepository;

  @override
  Future<Either<Failure, Institute>> call(UpdateInstituteRequest params) {
    return _institutesRepository.updateInstitute(params.slug, params.changes);
  }
}

/// Use case that lists the admin accounts of one institute.
class GetInstituteAdminsUsecase
    implements Usecase<List<InstituteAdmin>, InstituteSlugParams> {
  final InstitutesRepository _institutesRepository;

  GetInstituteAdminsUsecase({required InstitutesRepository institutesRepository})
    : _institutesRepository = institutesRepository;

  @override
  Future<Either<Failure, List<InstituteAdmin>>> call(
    InstituteSlugParams params,
  ) {
    return _institutesRepository.getInstituteAdmins(params.slug);
  }
}

/// Use case that moves an existing account into an institute.
class AssignAdminToInstituteUsecase
    implements Usecase<Unit, AssignAdminParams> {
  final InstitutesRepository _institutesRepository;

  AssignAdminToInstituteUsecase({
    required InstitutesRepository institutesRepository,
  }) : _institutesRepository = institutesRepository;

  @override
  Future<Either<Failure, Unit>> call(AssignAdminParams params) {
    return _institutesRepository.assignAdminToInstitute(
      profileId: params.profileId,
      slug: params.slug,
    );
  }
}

/// Use case that invites a new admin account for an institute.
class InviteInstituteAdminUsecase
    implements Usecase<InviteAdminResult, InviteAdminParams> {
  final InstitutesRepository _institutesRepository;

  InviteInstituteAdminUsecase({
    required InstitutesRepository institutesRepository,
  }) : _institutesRepository = institutesRepository;

  @override
  Future<Either<Failure, InviteAdminResult>> call(InviteAdminParams params) {
    return _institutesRepository.inviteAdmin(params);
  }
}

/// Which institute an institute-scoped call targets.
class InstituteSlugParams {
  final String slug;

  InstituteSlugParams({required this.slug});
}

/// An institute slug plus the fields to change.
class UpdateInstituteRequest {
  final String slug;
  final UpdateInstituteParams changes;

  UpdateInstituteRequest({required this.slug, required this.changes});
}

/// An account to move, and the institute to move it to.
class AssignAdminParams {
  final String profileId;
  final String slug;

  AssignAdminParams({required this.profileId, required this.slug});
}