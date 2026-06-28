import 'package:attendance_system_admin/core/models/user_model.dart';

class SignUpUserEntity {
  final String? id;
  final String name;
  final String email;
  final String password;
  final int phoneNumber;
  final bool rememberMe;
  final String organization;

  SignUpUserEntity({
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.rememberMe,
    required this.organization,
    required this.id,
    required this.password,
  });

  /// Converts this [SignUpUserEntity] to a [UserModel].
  UserModel toModel() {
    return UserModel(
      id: id ?? '',
      email: email,
      name: name,
      department: null,
      phoneNo: phoneNumber,
      userRole: null,
      organization: organization,
    );
  }
}
