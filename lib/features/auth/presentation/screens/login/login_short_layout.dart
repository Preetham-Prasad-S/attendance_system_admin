import 'package:attendance_system_admin/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:attendance_system_admin/features/auth/presentation/bloc/auth_event.dart';
import 'package:attendance_system_admin/features/auth/presentation/screens/signup/signup_screen.dart';
import 'package:attendance_system_admin/features/auth/presentation/widgets/auth_desktop_button_widget.dart';
import 'package:attendance_system_admin/features/auth/presentation/widgets/auth_desktop_check_box_widget.dart';
import 'package:attendance_system_admin/features/auth/presentation/widgets/auth_desktop_divider_widget.dart';
import 'package:attendance_system_admin/features/auth/presentation/widgets/auth_desktop_form_title_description_widget.dart';
import 'package:attendance_system_admin/features/auth/presentation/widgets/auth_desktop_login_credentials_widget.dart';
import 'package:attendance_system_admin/features/auth/presentation/widgets/auth_desktop_options_button_widget.dart';
import 'package:attendance_system_admin/features/auth/presentation/widgets/auth_desktop_signup_option_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginShortLayout extends StatefulWidget {
  const LoginShortLayout({super.key});
  @override
  State<LoginShortLayout> createState() => _ShortLayout();
}

class _ShortLayout extends State<LoginShortLayout> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            padding: EdgeInsets.all(40),
            width: 500,

            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AuthDesktopFormTitleDescriptionWidget(
                  titleText: "Welcome Back",
                  detailText: "Login to manage attendance records",
                ),

                SizedBox(height: 35),

                AuthDesktopLoginCredentialsWidget(
                  emailController: _emailController,
                  passwordController: _passwordController,
                ),

                SizedBox(height: 10),

                AuthDesktopCheckBoxWidget(
                  isChecked: _rememberMe,
                  onChanged: (value) {
                    setState(() {
                      _rememberMe = value ?? false;
                    });
                  },
                ),

                SizedBox(height: 20),

                AuthDesktopButtonWidget(
                  onPressed: () {
                    context.read<AuthBloc>().add(
                      LoginRequested(
                        email: _emailController.text.trim(),
                        password: _passwordController.text.trim(),
                        rememberMe: _rememberMe,
                      ),
                    );
                  },
                  text: "Login",
                ),

                SizedBox(height: 20),

                AuthDesktopDividerWidget(),

                SizedBox(height: 20),

                AuthDesktopOptionsButtonWidget(),

                SizedBox(height: 40),

                AuthDesktopSignupOptionWidget(
                  onTap: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => SignupScreen()),
                  ),
                  message: "Don't have an accoutn",
                  title: "SignUp",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
