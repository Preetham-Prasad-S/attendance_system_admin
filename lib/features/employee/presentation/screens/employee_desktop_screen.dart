import 'package:attendance_system_admin/features/employee/presentation/widgets/employee_info_widget.dart';
import 'package:attendance_system_admin/features/employee/presentation/widgets/employee_navigation_bar_widget.dart';
import 'package:attendance_system_admin/features/employee/presentation/widgets/employee_title_widget.dart';
import 'package:attendance_system_admin/features/employee/presentation/widgets/employee_table_widget.dart';
import 'package:flutter/material.dart';

class EmployeeDesktopScreen extends StatelessWidget {
  const EmployeeDesktopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EmployeeNavigationBarWidget(),
          const SizedBox(height: 40),
          EmployeeTitleWidget(),
          const SizedBox(height: 30),
          EmployeeInfoWidget(),
          const SizedBox(height: 30),
          EmployeeTableWidget(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
