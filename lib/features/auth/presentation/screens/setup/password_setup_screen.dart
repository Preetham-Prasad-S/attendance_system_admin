import 'package:attendance_system_admin/core/theme/app_colors.dart';
import 'package:attendance_system_admin/core/theme/app_radius.dart';
import 'package:attendance_system_admin/core/theme/app_spacing.dart';
import 'package:attendance_system_admin/core/theme/app_typography.dart';
import 'package:attendance_system_admin/features/auth/domain/usecases/complete_password_setup_usecase.dart';
import 'package:attendance_system_admin/features/auth/presentation/bloc/session_cubit.dart';
import 'package:attendance_system_admin/features/auth/presentation/bloc/session_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// First-login screen for an invited account.
///
/// Reached when a session exists but the profile is still `invited`
/// (migration 0008). The invitee sets a password here, which also flips their
/// profile to `active` and lets them into the shell.
class PasswordSetupScreen extends StatefulWidget {
  const PasswordSetupScreen({
    super.key,
    required this.completePasswordSetup,
    this.onCompleted,
  });

  /// Injected rather than pulled from the service locator so the screen can
  /// be driven directly in tests.
  final CompletePasswordSetupUsecase completePasswordSetup;

  /// Invoked after the account is activated. Defaults to re-running the
  /// session gate.
  final Future<void> Function()? onCompleted;

  @override
  State<PasswordSetupScreen> createState() => _PasswordSetupScreenState();
}

class _PasswordSetupScreenState extends State<PasswordSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isSubmitting = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  InputDecoration _decoration(String label, {String? helper}) =>
      InputDecoration(
        labelText: label,
        helperText: helper,
        helperStyle: AppTypography.caption.copyWith(
          color: AppColors.textMuted,
        ),
        labelStyle: AppTypography.label.copyWith(color: AppColors.textMuted),
        errorStyle: AppTypography.caption.copyWith(color: AppColors.danger),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
        suffixIcon: IconButton(
          onPressed: () => setState(() => _obscure = !_obscure),
          icon: Icon(
            _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            size: 18,
            color: AppColors.textMuted,
          ),
        ),
      );

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    final result = await widget.completePasswordSetup.call(
      _passwordController.text,
    );

    if (!mounted) return;

    result.fold(
      (failure) => setState(() {
        _isSubmitting = false;
        _error = failure.message;
      }),
      (_) async {
        setState(() => _isSubmitting = false);
        if (widget.onCompleted != null) {
          await widget.onCompleted!();
        } else if (context.mounted) {
          await context.read<SessionCubit>().reload();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SessionCubit>().state;
    final email = state is SessionInvited ? state.user.email : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Container(
            width: 420,
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: const Icon(
                          Icons.lock_outline,
                          color: AppColors.surface,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Set your password',
                              style: AppTypography.sectionTitle,
                            ),
                            if (email != null)
                              Text(
                                email,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textMuted,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Your administrator invited you to this institute. Choose a '
                    'password to finish setting up your account.',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (_error != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.dangerSurface,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 16,
                            color: AppColors.danger,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              _error!,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.danger,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscure,
                    decoration: _decoration(
                      'Password',
                      helper: 'At least 8 characters',
                    ),
                    validator: (value) {
                      final password = value ?? '';
                      if (password.isEmpty) return 'Choose a password';
                      if (password.length < 8) {
                        return 'Use at least 8 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _confirmController,
                    obscureText: _obscure,
                    decoration: _decoration('Confirm password'),
                    onFieldSubmitted: (_) => _submit(),
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.surface,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      textStyle: AppTypography.button,
                    ),
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.surface,
                            ),
                          )
                        : const Text('Set password & continue'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}