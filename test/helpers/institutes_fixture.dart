import 'package:attendance_system_admin/core/entities/account_status.dart';
import 'package:attendance_system_admin/core/entities/user_entity.dart';
import 'package:attendance_system_admin/features/institutes/domain/entities/institute_entity.dart';
import 'package:attendance_system_admin/features/institutes/domain/services/institute_context.dart';

const String tInstituteSlug = 'apex-institute-of-tech';
const String tOtherInstituteSlug = 'northgate-college';

const Institute tInstitute = Institute(
  id: 'institute-1',
  slug: tInstituteSlug,
  name: 'Apex Institute of Tech',
  code: 'Apex',
);

const Institute tOtherInstitute = Institute(
  id: 'institute-2',
  slug: tOtherInstituteSlug,
  name: 'Northgate College',
  code: 'NGC',
);

/// A context with [tInstitute] already selected, mirroring what SessionCubit
/// establishes before any page loads.
InstituteContext buildInstituteContext({UserEntity? user}) {
  final context = InstituteContext(currentUser: user);
  context.selectInstitute(tInstitute);
  return context;
}

UserEntity buildSuperAdmin({String organization = 'CampusPulse'}) =>
    UserEntity(
      id: 'user-1',
      email: 'root@example.com',
      name: 'Super Admin',
      department: null,
      phoneNo: null,
      role: 'super_admin',
      organization: organization,
    );

UserEntity buildRegularAdmin({String organization = 'CampusPulse'}) =>
    UserEntity(
      id: 'user-2',
      email: 'admin@example.com',
      name: 'Institute Admin',
      department: null,
      phoneNo: null,
      role: 'admin',
      organization: organization,
    );

/// An admin who has been invited but has not set a password yet.
UserEntity buildInvitedAdmin({String organization = 'CampusPulse'}) =>
    UserEntity(
      id: 'user-3',
      email: 'invited@example.com',
      name: 'Invited Admin',
      department: null,
      phoneNo: null,
      role: 'admin',
      organization: organization,
      status: AccountStatus.invited,
    );