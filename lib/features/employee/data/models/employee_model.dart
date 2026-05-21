import 'dart:convert';

class EmployeeModel {
  final String id;
  final String name;
  final String email;
  final String department;
  final String employeeType;

  EmployeeModel({
    required this.id,
    required this.name,
    required this.email,
    required this.department,
    required this.employeeType,
  });

  EmployeeModel copyWith({
    String? id,
    String? name,
    String? email,
    String? department,
    String? employeeType,
  }) {
    return EmployeeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      department: department ?? this.department,
      employeeType: employeeType ?? this.employeeType,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'department': department,
      'employeeType': employeeType,
    };
  }

  factory EmployeeModel.fromMap(Map<String, dynamic> map) {
    return EmployeeModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      department: map['department'] ?? '',
      employeeType: map['employeeType'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory EmployeeModel.fromJson(String source) =>
      EmployeeModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'EmployeeModel(id: $id, name: $name, email: $email, department: $department, employeeType: $employeeType)';
  }
}
