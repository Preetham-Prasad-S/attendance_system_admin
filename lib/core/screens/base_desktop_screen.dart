import 'package:attendance_system_admin/core/app_colors.dart';
import 'package:attendance_system_admin/core/widgets/custom_navigation_rail_widget.dart';
import 'package:attendance_system_admin/features/employee/presentation/screens/employee_desktop_screen.dart';
import 'package:flutter/material.dart';

class BaseDesktopScreen extends StatelessWidget {
  const BaseDesktopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.lightScaffoldColor,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomNavigationRailWidget(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: IndexedStack(children: [EmployeeDesktopScreen()]),
            ),
          ),
        ],
      ),
    );
  }
}
