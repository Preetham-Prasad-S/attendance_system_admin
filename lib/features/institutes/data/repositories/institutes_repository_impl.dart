import 'package:attendance_system_admin/core/failure.dart';
import 'package:attendance_system_admin/features/institutes/data/datasources/institutes_datasource.dart';
import 'package:attendance_system_admin/features/institutes/domain/entities/institute_entity.dart';
import 'package:attendance_system_admin/features/institutes/domain/repositories/institutes_repository.dart';
import 'package:fpdart/fpdart.dart';

class InstitutesRepositoryImpl implements InstitutesRepository {
  final InstitutesDatasource _institutesDatasource;

  InstitutesRepositoryImpl({required InstitutesDatasource institutesDatasource})
    : _institutesDatasource = institutesDatasource;

  @override
  Future<Either<Failure, List<Institute>>> getInstitutes() async {
    try {
      return Right(await _institutesDatasource.fetchInstitutes());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Institute>> createInstitute(
    CreateInstituteParams params,
  ) async {
    try {
      return Right(await _institutesDatasource.createInstitute(params));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Institute>> updateInstitute(
    String slug,
    UpdateInstituteParams params,
  ) async {
    try {
      return Right(await _institutesDatasource.updateInstitute(slug, params));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<InstituteAdmin>>> getInstituteAdmins(
    String slug,
  ) async {
    try {
      return Right(await _institutesDatasource.fetchInstituteAdmins(slug));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> assignAdminToInstitute({
    required String profileId,
    required String slug,
  }) async {
    try {
      await _institutesDatasource.assignAdminToInstitute(
        profileId: profileId,
        slug: slug,
      );
      return Right(unit);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, InviteAdminResult>> inviteAdmin(
    InviteAdminParams params,
  ) async {
    try {
      return Right(await _institutesDatasource.inviteAdmin(params));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}