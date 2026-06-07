import 'package:attendance_system_admin/core/app_colors.dart';
import 'package:attendance_system_admin/features/auth/presentation/screens/signup/signup_desktop_screen.dart';
import 'package:attendance_system_admin/features/auth/presentation/screens/signup/signup_mobile_screen.dart';
import 'package:attendance_system_admin/features/auth/presentation/screens/signup/signup_short_screen.dart';
import 'package:flutter/material.dart';


class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<StatefulWidget> createState() => _SignupScreen();
}

class _SignupScreen extends State<SignupScreen> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.lightScaffoldColor,

      body: Column(
        children: [
          if (width > 1000)
            SignupDesktopScreen()
          else if (width > 500)
            SignupShortScreen()
          else
            SignupMobileScreen(),
        ],
      ),
    );
  }
}


