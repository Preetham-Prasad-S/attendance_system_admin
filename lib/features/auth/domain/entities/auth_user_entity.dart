import 'package:attendance_system_admin/features/auth/data/models/user_model.dart';

class AuthUserEntity {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;

  AuthUserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
  });

  /// Creates an [AuthUserEntity] from a [UserModel].
  factory AuthUserEntity.fromModel(UserModel model) {
    return AuthUserEntity(
      id: model.id,
      name: model.name,
      email: model.email,
      phoneNumber: model.phoneNo,
    );
  }

  /// Converts this [AuthUserEntity] to a [UserModel].
  UserModel toModel() {
    return UserModel(
      id: id,
      name: name,
      email: email,
      phoneNo: phoneNumber,
      department: null,
      userRole: null,
    );
  }
}
