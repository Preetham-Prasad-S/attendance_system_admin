import 'dart:convert';

class UserModel {
  final String id;
  final String email;
  final String name;
  final String? department;
  final String organization;
  final String phoneNo;
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

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      email: map['email'] as String,
      name: map['name'] as String,
      department: map['department'] as String,
      phoneNo: map['phoneNo'] as String,
      userRole: map['userRole'] as String,
      organization: map["organization"] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
