import 'package:flutter/material.dart';
import 'auth_textfield_widget.dart';

class AuthDesktopLoginCredentialsWidget extends StatefulWidget {
  final TextEditingController _emailController;
  final TextEditingController _passwordController;
  const AuthDesktopLoginCredentialsWidget({
    super.key,
    required TextEditingController emailController,
    required TextEditingController passwordController,
  }) : _passwordController = passwordController,
       _emailController = emailController;

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
        SizedBox(height: 10),
        AuthTextFieldWidget(
          textEditingController: widget._emailController,
          hintText: "name@company.com",
          labelText: "Email Address",
        ),
        SizedBox(height: 10),
        SizedBox(height: 10),
        AuthTextFieldWidget(
          textEditingController: widget._passwordController,
          hintText: "•••••••••••",
          isPassword: true,
          labelText: "Password",
        ),
      ],
    );
  }
}
