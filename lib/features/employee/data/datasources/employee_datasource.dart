import 'package:attendance_system_admin/features/employee/data/models/employee_model.dart';

abstract interface class EmployeeDatasource {
  Future<EmployeeModel> addEmployee(EmployeeModel employee);
}
