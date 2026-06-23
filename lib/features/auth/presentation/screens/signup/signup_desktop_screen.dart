import 'package:attendance_system_admin/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:attendance_system_admin/features/auth/presentation/bloc/auth_event.dart';
import 'package:attendance_system_admin/features/auth/presentation/widgets/auth_desktop_button_widget.dart';
import 'package:attendance_system_admin/features/auth/presentation/widgets/auth_desktop_check_box_widget.dart';
import 'package:attendance_system_admin/features/auth/presentation/widgets/auth_desktop_divider_widget.dart';
import 'package:attendance_system_admin/features/auth/presentation/widgets/auth_desktop_form_title_description_widget.dart';
import 'package:attendance_system_admin/features/auth/presentation/widgets/auth_desktop_image_description_widget.dart';
import 'package:attendance_system_admin/features/auth/presentation/widgets/auth_desktop_image_widget.dart';
import 'package:attendance_system_admin/features/auth/presentation/widgets/auth_desktop_options_button_widget.dart';
import 'package:attendance_system_admin/features/auth/presentation/widgets/auth_desktop_signup_option_widget.dart';
import 'package:attendance_system_admin/features/auth/presentation/widgets/auth_textfield_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../widgets/login_image_title_widget.dart';

class SignupDesktopScreen extends StatefulWidget {
  const SignupDesktopScreen({super.key});

  @override
  State<SignupDesktopScreen> createState() => _SignupDesktopScreenState();
}

class _SignupDesktopScreenState extends State<SignupDesktopScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _nameController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  late final TextEditingController _phoneNumberController;
  late final TextEditingController _organizationController;

  bool _rememberMe = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _nameController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _organizationController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Expanded(
            child: Container(
              color: const Color.fromARGB(255, 255, 255, 255),
              padding: EdgeInsets.only(left: 45, top: 45, right: 25),
              child: SizedBox(
                width: 500,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LoginImageTitleWidget(),
                    SizedBox(height: 10),

                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AuthDesktopImageWidget(
                              imageUrl: "assets/login-screen-picture.png",
                            ),
                            SizedBox(height: 15),

                            AuthDesktopImageDescriptionWidget(
                              titleText: "Precision Workforce Tracking",
                              subTitleText:
                                  "Experience the future of attendance management with our cutting-edge isometric reporting and real-time kiosk integration.",
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: Center(
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
                    width: 600,

                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AuthDesktopFormTitleDescriptionWidget(
                          titleText: "Create An Account",
                          detailText:
                              "Setup your workspace to begin managing your team",
                        ),

                        SizedBox(height: 35),

                        Form(
                          key: _formKey,
                          child: AuthSigupCredentialWidget(
                            organizationController: _organizationController,
                            emailController: _emailController,
                            passwordController: _passwordController,
                            confirmPasswordController:
                                _confirmPasswordController,
                            phoneNumberController: _phoneNumberController,
                            nameController: _nameController,
                          ),
                        ),

                        AuthDesktopCheckBoxWidget(
                          isChecked: _rememberMe,
                          onChanged: (value) {
                            setState(() {
                              _rememberMe = value ?? false;
                            });
                          },
                        ),

                        SizedBox(height: 15),

                        AuthDesktopButtonWidget(
                          onPressed: () {
                            context.read<AuthBloc>().add(
                              SignupRequested(
                                email: _emailController.text.trim(),
                                name: _nameController.text.trim(),
                                password: _passwordController.text.trim(),
                                organization: _organizationController.text
                                    .trim(),
                                phoneNumber: _phoneNumberController.text.trim(),
                                rememberMe: _rememberMe,
                              ),
                            );
                          },
                          text: "SignUp",
                        ),

                        SizedBox(height: 15),

                        AuthDesktopDividerWidget(),

                        SizedBox(height: 15),

                        AuthDesktopOptionsButtonWidget(),

                        SizedBox(height: 15),

                        AuthDesktopSignupOptionWidget(
                          message: "Already have an account",
                          title: "Login",
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthSigupCredentialWidget extends StatelessWidget {
  final TextEditingController _emailController;
  final TextEditingController _nameController;
  final TextEditingController _passwordController;
  final TextEditingController _confirmPasswordController;
  final TextEditingController _phoneNumberController;
  final TextEditingController _organizationController;

  const AuthSigupCredentialWidget({
    super.key,
    required TextEditingController emailController,
    required TextEditingController nameController,
    required TextEditingController passwordController,
    required TextEditingController confirmPasswordController,
    required TextEditingController phoneNumberController,
    required TextEditingController organizationController,
  }) : _confirmPasswordController = confirmPasswordController,
       _organizationController = organizationController,
       _emailController = emailController,
       _nameController = nameController,
       _passwordController = passwordController,
       _phoneNumberController = phoneNumberController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Flexible(
              child: AuthTextFieldWidget(
                textEditingController: _nameController,
                hintText: "John Doe DK",
                labelText: "Full Name",
              ),
            ),
            SizedBox(width: 20),
            Flexible(
              child: AuthTextFieldWidget(
                textEditingController: _organizationController,
                hintText: "ABC Private Limited",
                labelText: "Organization Name",
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Flexible(
              child: AuthTextFieldWidget(
                textEditingController: _emailController,
                hintText: "example@gmail.com",
                labelText: "Work Email",
              ),
            ),
            SizedBox(width: 20),

            Flexible(
              child: AuthTextFieldWidget(
                textEditingController: _phoneNumberController,
                hintText: "+91 1234567890",
                labelText: "Phone Number  ",
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Flexible(
              child: AuthTextFieldWidget(
                textEditingController: _passwordController,
                hintText: "•••••••••••",
                labelText: "Password",
              ),
            ),
            SizedBox(width: 20),
            Flexible(
              child: AuthTextFieldWidget(
                textEditingController: _confirmPasswordController,
                hintText: "•••••••••••",
                labelText: "Confirm Password",
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
