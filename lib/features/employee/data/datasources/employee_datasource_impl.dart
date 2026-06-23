import 'package:attendance_system_admin/features/employee/data/datasources/employee_datasource.dart';
import 'package:attendance_system_admin/features/employee/data/models/employee_model.dart';

class EmployeeDatasourceImpl implements EmployeeDatasource {
  @override
  Future<EmployeeModel> addEmployee(EmployeeModel employee) {
    throw UnimplementedError();
  }

  @override
  Future<List<EmployeeModel>> getEmployees() {
    throw UnimplementedError();
  }
}
