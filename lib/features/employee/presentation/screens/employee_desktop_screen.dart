import 'package:attendance_system_admin/features/employee/presentation/widgets/employee_navigation_bar_widget.dart';
import 'package:flutter/material.dart';

class EmployeeDesktopScreen extends StatelessWidget {
  const EmployeeDesktopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        EmployeeNavigationBarWidget(),
        SizedBox(height: 40),
        Column(children: [Text("User Management")]),
      ],
    );
  }
}
