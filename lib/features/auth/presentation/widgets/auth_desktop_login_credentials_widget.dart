import 'package:attendance_system_admin/features/auth/presentation/widgets/auth_textfield_widget.dart';
import 'package:flutter/material.dart';

class AuthDesktopLoginCredentialsWidget extends StatefulWidget {
  const AuthDesktopLoginCredentialsWidget({super.key});

  @override
  State<AuthDesktopLoginCredentialsWidget> createState() =>
      _AuthDesktopLoginCredentialWidget();
}

class _AuthDesktopLoginCredentialWidget
    extends State<AuthDesktopLoginCredentialsWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        const AuthTextFieldWidget(
          hintText: "name@company.com",
          labelText: "Email Address",
        ),
        const SizedBox(height: 10),
        const SizedBox(height: 10),
        const AuthTextFieldWidget(
          hintText: "•••••••••••",
          isPassword: true,
          labelText: "Password",
        ),
      ],
    );
  }
}
