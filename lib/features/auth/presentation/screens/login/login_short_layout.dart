import 'package:attendance_system_admin/core/failure.dart';
import 'package:attendance_system_admin/core/theme/app_colors.dart';
import 'package:attendance_system_admin/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:attendance_system_admin/features/auth/presentation/bloc/auth_event.dart';
import 'package:attendance_system_admin/features/auth/presentation/widgets/auth_form_error_widget.dart';
import 'package:colorful_iconify_flutter/icons/logos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/iconify_flutter.dart';

import '../../widgets/auth_textfield_widget.dart';

class LoginShortLayout extends StatefulWidget {
  const LoginShortLayout({super.key});
  @override
  State<LoginShortLayout> createState() => _ShortLayout();
}

class _ShortLayout extends State<LoginShortLayout> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShortLoginTitleDescriptionWIdget(),

                SizedBox(height: 15),

                ShortLoginPasswordWidget(
                  emailController: _emailController,
                  passwordController: _passwordController,
                ),

                SizedBox(height: 10),

                ShortLoginChechboxWidget(),

                SizedBox(height: 20),

                AuthFormErrorWidget(),

                ShortLoginLoginButtonWidget(
                  onPressed: () {
                    context.read<AuthBloc>().add(
                      LoginRequested(
                        email: _emailController.text.trim(),
                        password: _passwordController.text.trim(),
                      ),
                    );
                  },
                ),

                SizedBox(height: 20),

                ShortLoginDividerWidget(),

                SizedBox(height: 20),

                ShortLoginOptionsButtonWidget(),

                SizedBox(height: 40),

                ShortLoginSignupOptionWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ShortLoginPasswordWidget extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const ShortLoginPasswordWidget({
    super.key,
    required this.emailController,
    required this.passwordController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Email Address",
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),

        SizedBox(height: 10),
        AuthTextFieldWidget(
          textEditingController: emailController,
          hintText: "name@company.com",
          labelText: "Email Address",
          errorField: AuthErrorField.email,
        ),

        SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                "Password",
                style: GoogleFonts.quicksand(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),

            InkWell(
              onTap: () {},
              child: Text(
                "Forgot Password ?",
                style: GoogleFonts.quicksand(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 10),

        AuthTextFieldWidget(
          textEditingController: passwordController,
          hintText: "•••••••••••",
          isPassword: true,
          labelText: 'Password',
          errorField: AuthErrorField.password,
        ),
      ],
    );
  }
}

class ShortLoginChechboxWidget extends StatefulWidget {
  const ShortLoginChechboxWidget({super.key});
  @override
  State<ShortLoginChechboxWidget> createState() => _ShortLoginChechboxWidget();
}

class _ShortLoginChechboxWidget extends State<ShortLoginChechboxWidget> {
  bool isChecked = false;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: isChecked,
          onChanged: (bool? newValue) {
            setState(() {
              isChecked = newValue ?? false;
            });
          },
          activeColor: Colors.blue,
          checkColor: Colors.white,
        ),
        Text("Remember Me"),
      ],
    );
  }
}

class ShortLoginSignupOptionWidget extends StatelessWidget {
  const ShortLoginSignupOptionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account?",
          textAlign: TextAlign.center,
          style: GoogleFonts.quicksand(fontWeight: FontWeight.w500),
        ),

        SizedBox(width: 5),

        InkWell(
          onTap: () {},
          child: Text(
            "Sign Up",
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.w500,
              color: Color.fromRGBO(48, 102, 208, 1),
            ),
          ),
        ),
      ],
    );
  }
}

class ShortLoginOptionsButtonWidget extends StatelessWidget {
  const ShortLoginOptionsButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextButton.icon(
            onPressed: () {},
            label: Text(
              "Google",
              style: GoogleFonts.quicksand(
                color: Colors.black,
                fontWeight: FontWeight.w400,
              ),
            ),
            icon: Iconify(Logos.google_icon, size: 20),
            style: TextButton.styleFrom(
              overlayColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
                side: BorderSide(
                  color: Color.fromRGBO(199, 195, 195, 1),
                  width: 1.5,
                ),
              ),
              minimumSize: Size(double.infinity, 50),
            ),
          ),
        ),

        SizedBox(width: 20),
        Expanded(
          child: TextButton.icon(
            onPressed: () {},
            label: Text(
              "Microsoft",
              style: GoogleFonts.quicksand(
                color: Colors.black,
                fontWeight: FontWeight.w400,
              ),
            ),
            icon: Iconify(Logos.microsoft_icon, size: 20),
            style: TextButton.styleFrom(
              overlayColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
                side: BorderSide(
                  color: Color.fromRGBO(199, 195, 195, 1),
                  width: 1.5,
                ),
              ),
              minimumSize: Size(double.infinity, 50),
            ),
          ),
        ),
      ],
    );
  }
}

class ShortLoginDividerWidget extends StatelessWidget {
  const ShortLoginDividerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(thickness: 1.5, color: Colors.grey)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.0),
          child: Text(
            "OR",
            style: GoogleFonts.quicksand(
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(child: Divider(thickness: 1.5, color: Colors.grey)),
      ],
    );
  }
}

class ShortLoginLoginButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;

  const ShortLoginLoginButtonWidget({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        minimumSize: Size(double.infinity, 50),
        foregroundColor: Color.fromRGBO(255, 255, 255, 1),
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(10),
        ),
      ),
      child: Text(
        "Login",
        style: GoogleFonts.quicksand(fontSize: 20, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class ShortLoginTitleDescriptionWIdget extends StatelessWidget {
  const ShortLoginTitleDescriptionWIdget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Welcome Back",
          style: GoogleFonts.quicksand(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),

        SizedBox(height: 10),

        Text(
          "Login to manage attendance records",
          style: GoogleFonts.quicksand(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color.fromRGBO(0, 0, 0, 1),
          ),
        ),
      ],
    );
  }
}
