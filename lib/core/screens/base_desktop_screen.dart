import 'package:attendance_system_admin/core/app_colors.dart';
import 'package:flutter/material.dart';

class BaseDesktopScreen extends StatelessWidget {
  const BaseDesktopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.lightScaffoldColor,
      body: Row(
        children: [
          Container(
            margin: EdgeInsets.all(20),
            height: double.infinity,
            width: 350,
            decoration: BoxDecoration(color: AppColors.whiteColor),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: IndexedStack(children: [Container(color: Colors.blue)]),
            ),
          ),
        ],
      ),
    );
  }
}
