import 'dart:convert';

class UserModel {
  final String id;
  final String email;
  final String name;
  final String? department;
  final String organization;
  final String? phoneNo;
  final String? role;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.department,
    required this.phoneNo,
    required this.role,
    required this.organization,
  });

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? department,
    String? organization,
    String? phoneNo,
    String? role,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      department: department ?? this.department,
      organization: organization ?? this.organization,
      phoneNo: phoneNo ?? this.phoneNo,
      role: role ?? this.role,
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
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
