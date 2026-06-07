import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:attendance_system_admin/core/app_colors.dart';
import 'auth_textfield_widget.dart';

class AuthDesktopLoginCredentialsWidget extends StatefulWidget {
  const AuthDesktopLoginCredentialsWidget({super.key});

  @override
  State<AuthDesktopLoginCredentialsWidget> createState() => _AuthDesktopLoginCredentialWidget();
}

class _AuthDesktopLoginCredentialWidget extends State<AuthDesktopLoginCredentialsWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        SizedBox(height: 10),
        AuthTextFieldWidget(
          hintText: "name@company.com",
          labelText: "Email Address",
        ),
        SizedBox(height: 10),
        SizedBox(height: 10),
        AuthTextFieldWidget(
          hintText: "•••••••••••",
          isPassword: true,
          labelText: "Password",
        ),
      ],
    );
  }
}
