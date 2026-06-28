import 'dart:convert';
import '../models/user_model.dart';

class UserEntity {
  final String id;
  final String email;
  final String name;
  final String? department;
  final String organization;
  final int phoneNo;
  final String? userRole;

  UserEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.department,
    required this.phoneNo,
    required this.userRole,
    required this.organization,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'email': email,
      'name': name,
      'department': department,
      'phoneNo': phoneNo,
      'userRole': userRole,
    };
  }

  factory UserEntity.fromMap(Map<String, dynamic> map) {
    return UserEntity(
      id: map['id'] as String,
      email: map['email'] as String,
      name: map['name'] as String,
      department: map['department'] as String,
      phoneNo: map['phoneNo'] as int,
      userRole: map['userRole'] as String,
      organization: map['organization'] as String,
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
      userRole: userRole,
      organization: organization,
    );
  }

  factory UserEntity.fromModel(UserModel model) {
    return UserEntity(
      id: model.id,
      email: model.email,
      name: model.name,
      department: model.department,
      phoneNo: model.phoneNo,
      userRole: model.userRole,
      organization: model.organization,
    );
  }
}
