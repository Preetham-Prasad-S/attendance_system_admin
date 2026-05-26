import 'package:attendance_system_admin/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'login_desktop_layout.dart';
import 'login_mobile_layout.dart';
import 'login_short_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<StatefulWidget> createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.lightScaffoldColor,

      body: Column(
        children: [
          if (width < 1000 && width > 505)
            LoginShortLayout()
          else if (width < 505)
            LoginMobilelayout()
          else
            LoginDesktopLayout(),
        ],
      ),
    );
  }
}
