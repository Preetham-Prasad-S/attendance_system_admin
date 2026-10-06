import 'package:attendance_system_admin/core/failure.dart';
import 'package:attendance_system_admin/core/theme/app_colors.dart';
import 'package:attendance_system_admin/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:attendance_system_admin/features/auth/presentation/bloc/auth_event.dart';
import 'package:attendance_system_admin/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthTextFieldWidget extends StatefulWidget {
  final String hintText;
  final String labelText;
  final bool isPassword;
  final TextEditingController textEditingController;

  /// When set, this field shows [AuthFailureState] messages for [errorField]
  /// (instead of a snackbar) and clears that error as the user types.
  final AuthErrorField? errorField;

  const AuthTextFieldWidget({
    super.key,
    required this.hintText,
    required this.labelText,
    required this.textEditingController,
    this.isPassword = false,
    this.errorField,
  });
  @override
  State<AuthTextFieldWidget> createState() => _AuthTextFieldWidget();
}

class _AuthTextFieldWidget extends State<AuthTextFieldWidget> {
  bool textHide = true;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final errorText =
            state is AuthFailureState && state.field == widget.errorField
            ? state.message
            : null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.labelText,
              style: GoogleFonts.quicksand(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: widget.textEditingController,
              validator: (value) => null,
              cursorColor: AppColors.primary,
              style: GoogleFonts.quicksand(fontWeight: FontWeight.w500),
              obscureText: widget.isPassword ? textHide : false,
              onChanged: widget.errorField == null
                  ? null
                  : (_) => context.read<AuthBloc>().add(
                      AuthInputChanged(widget.errorField!),
                    ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                errorText: errorText,
                errorMaxLines: 2,
                errorStyle: GoogleFonts.quicksand(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                hintStyle: GoogleFonts.quicksand(
                  color: Color.fromRGBO(64, 63, 63, 0.673),
                  fontSize: 14,
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary, width: 2),

                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1.5),

                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: widget.isPassword
                    ? IconButton(
                        onPressed: () {
                          setState(() {
                            textHide = !textHide;
                          });
                        },
                        icon: Icon(
                          textHide ? Icons.visibility : Icons.visibility_off,
                        ),
                        color: Color.fromRGBO(108, 108, 109, 1),
                      )
                    : null,
              ),
            ),
          ],
        );
      },
    );
  }
}
