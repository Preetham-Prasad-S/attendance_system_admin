import 'package:attendance_system_admin/core/theme/app_colors.dart';
import 'package:attendance_system_admin/core/theme/app_radius.dart';
import 'package:attendance_system_admin/core/theme/app_spacing.dart';
import 'package:attendance_system_admin/core/theme/app_typography.dart';
import 'package:attendance_system_admin/features/institutes/domain/entities/institute_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Create/edit form for an institute. Minimal record per D8: name, code and
/// the active flag. [Institute] is null when creating.
class InstituteFormDialog extends StatefulWidget {
  const InstituteFormDialog({super.key, this.institute});

  final Institute? institute;

  bool get isEditing => institute != null;

  @override
  State<InstituteFormDialog> createState() => _InstituteFormDialogState();
}

class _InstituteFormDialogState extends State<InstituteFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _codeController;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.institute?.name ?? '');
    _codeController = TextEditingController(text: widget.institute?.code ?? '');
    _isActive = widget.institute?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
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

  @override
  Widget build(BuildContext context) {
    final slugPreview = slugifyInstituteName(
      _nameController.text,
    );

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      title: Text(
        widget.isEditing ? 'Edit institute' : 'Add institute',
        style: AppTypography.sectionTitle,
      ),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                autofocus: true,
                decoration: _decoration('Institute name'),
                textCapitalization: TextCapitalization.words,
                onChanged: (_) => setState(() {}),
                validator: (value) {
                  final name = value?.trim() ?? '';
                  if (name.isEmpty) return 'Enter a name';
                  if (slugifyInstituteName(name).isEmpty) {
                    return 'Use at least one letter or number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _codeController,
                decoration: _decoration('Code (optional)'),
                inputFormatters: [LengthLimitingTextInputFormatter(16)],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Slug: $slugPreview',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              if (widget.isEditing) ...[
                const SizedBox(height: AppSpacing.md),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Active', style: AppTypography.label),
                  subtitle: Text(
                    'Inactive institutes stay in the registry but are hidden '
                    'from the switcher.',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  value: _isActive,
                  onChanged: (value) => setState(() => _isActive = value),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.surface,
          ),
          onPressed: () {
            if (!(_formKey.currentState?.validate() ?? false)) return;
            Navigator.of(context).pop(
              InstituteFormResult(
                name: _nameController.text.trim(),
                code: _codeController.text.trim(),
                isActive: _isActive,
              ),
            );
          },
          child: Text(widget.isEditing ? 'Save changes' : 'Create institute'),
        ),
      ],
    );
  }
}

/// What the form returns to the page, which turns it into a bloc event.
class InstituteFormResult {
  const InstituteFormResult({
    required this.name,
    required this.code,
    required this.isActive,
  });

  final String name;
  final String code;
  final bool isActive;

  CreateInstituteParams get createParams =>
      CreateInstituteParams(name: name, code: code.isEmpty ? null : code);

  UpdateInstituteParams get updateParams => UpdateInstituteParams(
    name: name,
    code: code.isEmpty ? null : code,
    isActive: isActive,
  );
}