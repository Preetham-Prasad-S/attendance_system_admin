import 'dart:convert';

import 'package:attendance_system_admin/core/entities/account_status.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final String? department;
  final String organization;
  final String? phoneNo;
  final String? role;

  /// Invited / active lifecycle (migration 0008).
  final AccountStatus status;

  /// Profile id of the super admin who invited this account, if any.
  final String? invitedBy;

  UserModel({
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

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? department,
    String? organization,
    String? phoneNo,
    String? role,
    AccountStatus? status,
    String? invitedBy,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      department: department ?? this.department,
      organization: organization ?? this.organization,
      phoneNo: phoneNo ?? this.phoneNo,
      role: role ?? this.role,
      status: status ?? this.status,
      invitedBy: invitedBy ?? this.invitedBy,
    );
  }

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

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
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

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);
}