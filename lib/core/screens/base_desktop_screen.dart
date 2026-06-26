import 'package:attendance_system_admin/core/app_colors.dart';
import 'package:attendance_system_admin/core/widgets/custom_navigation_rail_widget.dart';
import 'package:attendance_system_admin/features/employee/presentation/screens/employee_desktop_screen.dart';
import 'package:flutter/material.dart';

import 'base_right_drawer.dart';

class BaseDesktopScreen extends StatefulWidget {
  const BaseDesktopScreen({super.key});

  @override
  State<BaseDesktopScreen> createState() => _BaseDesktopScreenState();
}

class _BaseDesktopScreenState extends State<BaseDesktopScreen> {
  @override
  Widget build(BuildContext context) {
    // final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.lightScaffoldColor,
      body: Row(
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
      endDrawer: BaseRightDrawer()
    );
  }
}