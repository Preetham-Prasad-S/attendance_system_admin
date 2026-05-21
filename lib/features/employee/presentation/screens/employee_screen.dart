import 'package:attendance_system_admin/features/employee/presentation/screens/employee_desktop_screen.dart';
import 'package:attendance_system_admin/features/employee/presentation/screens/employee_mobile_screen.dart';
import 'package:flutter/material.dart';

class EmployeeScreen extends StatelessWidget {
  const EmployeeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 450) {
          return EmployeeMobileScreen();
        }
        return EmployeeDesktopScreen();
      },
    );
  }
}
