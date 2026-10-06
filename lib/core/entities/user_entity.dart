import 'dart:convert';

import 'package:attendance_system_admin/core/entities/account_status.dart';

import '../models/user_model.dart';

class UserEntity {
  final String id;
  final String email;
  final String name;
  final String? department;
  final String organization;
  final String? phoneNo;
  final String? role;
  final AccountStatus status;
  final String? invitedBy;

  UserEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.department,
    required this.phoneNo,
    required this.role,
    required this.organization,
    this.status = AccountStatus.active,
    this.invitedBy,
  });

  /// Whether this account may switch between institutes and manage them.
  bool get isSuperAdmin => role == 'super_admin';

  /// Whether this account has completed password setup.
  bool get isActivated => status.isActive;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'email': email,
      'name': name,
      'department': department,
      'organization': organization,
      'phone_no': phoneNo,
      'role': role,
      'status': status.name,
      'invited_by': invitedBy,
    };
  }

  factory UserEntity.fromMap(Map<String, dynamic> map) {
    return UserEntity(
      id: map['id'] as String,
      email: map['email'] as String,
      name: map['name'] as String,
      department: map['department'] as String?,
      organization: map['organization'] as String,
      phoneNo: map['phone_no'] as String?,
      role: map['role'] as String?,
      status: AccountStatus.fromString(map['status'] as String?),
      invitedBy: map['invited_by'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserEntity.fromJson(String source) =>
      UserEntity.fromMap(json.decode(source) as Map<String, dynamic>);

  UserModel toModel() {
    return UserModel(
      id: id,
      email: email,
      name: name,
      department: department,
      phoneNo: phoneNo,
      role: role,
      organization: organization,
      status: status,
      invitedBy: invitedBy,
    );
  }

  factory UserEntity.fromModel(UserModel model) {
    return UserEntity(
      id: model.id,
      email: model.email,
      name: model.name,
      department: model.department,
      phoneNo: model.phoneNo,
      role: model.role,
      organization: model.organization,
      status: model.status,
      invitedBy: model.invitedBy,
    );
  }
}