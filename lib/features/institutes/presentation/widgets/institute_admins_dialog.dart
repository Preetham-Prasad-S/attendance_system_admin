import 'package:attendance_system_admin/core/theme/app_colors.dart';
import 'package:attendance_system_admin/core/theme/app_radius.dart';
import 'package:attendance_system_admin/core/theme/app_spacing.dart';
import 'package:attendance_system_admin/core/theme/app_typography.dart';
import 'package:attendance_system_admin/features/institutes/domain/entities/institute_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Admin accounts of one institute, plus the invite form.
///
/// The invite is created server-side by the `create-institute-admin` Edge
/// Function because creating an `auth.users` row needs the service_role key;
/// the resulting setup link is shown for the super admin to pass on.
class InstituteAdminsDialog extends StatefulWidget {
  const InstituteAdminsDialog({
    super.key,
    required this.institute,
    required this.admins,
    required this.isLoading,
    required this.isSubmitting,
    required this.setupLink,
  });

  final Institute institute;
  final List<InstituteAdmin> admins;
  final bool isLoading;
  final bool isSubmitting;
  final String? setupLink;

  @override
  State<InstituteAdminsDialog> createState() => _InstituteAdminsDialogState();
}

class _InstituteAdminsDialogState extends State<InstituteAdminsDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  InputDecoration _decoration(String label) => InputDecoration(
    labelText: label,
    labelStyle: AppTypography.label.copyWith(color: AppColors.textMuted),
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
  );

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(
      InviteAdminParams(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        instituteSlug: widget.institute.slug,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      title: Text(
        'Admins · ${widget.institute.name}',
        style: AppTypography.sectionTitle,
      ),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (widget.admins.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  child: Text(
                    'No admins yet. Invite the first one below.',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                )
              else
                for (final admin in widget.admins)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                admin.name,
                                style: AppTypography.label.copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                admin.email,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _AdminStatusPill(isPending: admin.isPending),
                      ],
                    ),
                  ),
              if (widget.setupLink != null) ...[
                const SizedBox(height: AppSpacing.md),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.successSurface,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Setup link created',
                        style: AppTypography.label.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.successDark,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      SelectableText(
                        widget.setupLink!,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const Divider(height: AppSpacing.xl),
              Text(
                'Invite an admin',
                style: AppTypography.label.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'They will set their own password the first time they sign in.',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: _decoration('Full name'),
                      textCapitalization: TextCapitalization.words,
                      validator: (value) => (value?.trim().isEmpty ?? true)
                          ? 'Enter their name'
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _emailController,
                      decoration: _decoration('Email address'),
                      keyboardType: TextInputType.emailAddress,
                      inputFormatters: [
                        TextInputFormatter.withFunction(
                          (_, value) => value.copyWith(
                            text: value.text.replaceAll(RegExp(r'\s'), ''),
                          ),
                        ),
                      ],
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        if (email.isEmpty) return 'Enter their email address';
                        if (!email.contains('@') || !email.contains('.')) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.surface,
          ),
          onPressed: widget.isSubmitting ? null : _submit,
          child: Text(
            widget.isSubmitting ? 'Inviting…' : 'Send invitation',
          ),
        ),
      ],
    );
  }
}

class _AdminStatusPill extends StatelessWidget {
  const _AdminStatusPill({required this.isPending});

  final bool isPending;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 1,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: isPending ? AppColors.warningSurface : AppColors.successSurface,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        isPending ? 'Invited' : 'Active',
        style: AppTypography.caption.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isPending ? AppColors.warningDark : AppColors.successDark,
        ),
      ),
    );
  }
}