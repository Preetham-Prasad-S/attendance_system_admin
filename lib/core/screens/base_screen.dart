import 'package:attendance_system_admin/core/screens/base_desktop_screen.dart';
import 'package:attendance_system_admin/core/screens/base_mobile_screen.dart';
import 'package:flutter/material.dart';

class BaseScreen extends StatelessWidget {
  const BaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 550) {
            return BaseMobileScreen();
          }
          return BaseDesktopScreen();
        },
      ),
    );
  }
}
