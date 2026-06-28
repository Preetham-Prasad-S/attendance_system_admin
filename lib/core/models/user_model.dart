import 'dart:convert';

class UserModel {
  final String id;
  final String email;
  final String name;
  final String? department;
  final String organization;
  final int phoneNo;
  final String? userRole;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.department,
    required this.phoneNo,
    required this.userRole,
    required this.organization,
  });

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? department,
    String? organization,
    int? phoneNo,
    String? userRole,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      department: department ?? this.department,
      organization: organization ?? this.organization,
      phoneNo: phoneNo ?? this.phoneNo,
      userRole: userRole ?? this.userRole,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'email': email,
      'name': name,
      'department': department,
      'phoneNo': phoneNo,
      'userRole': userRole,
      'organization': organization,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      email: map['email'] as String,
      name: map['name'] as String,
      department: map['department'] as String,
      phoneNo: map['phoneNo'] as int,
      userRole: map['userRole'] as String?,
      organization: map["organization"] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
