import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/students_entities.dart';
import '../bloc/students_bloc.dart';
import '../bloc/students_event.dart';
import '../bloc/students_state.dart';

/// Dialog form to create a student. Submits via [AddStudentRequested] and
/// closes itself on success; validation/unique-violation errors show inline.
class StudentsAddDialog extends StatefulWidget {
  const StudentsAddDialog({super.key});

  @override
  State<StudentsAddDialog> createState() => _StudentsAddDialogState();
}

class _StudentsAddDialogState extends State<StudentsAddDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _rollController = TextEditingController();
  final _emailController = TextEditingController();
  String? _department;
  String _status = 'active';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = context.read<StudentsBloc>().state;
      if (state is StudentsLoaded &&
          (state.addError != null || state.addSuccess != null)) {
        context.read<StudentsBloc>().add(AddFeedbackCleared());
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rollController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final email = _emailController.text.trim();
    context.read<StudentsBloc>().add(
      AddStudentRequested(
        params: AddStudentParams(
          name: _nameController.text.trim(),
          studentNo: _rollController.text.trim(),
          email: email.isEmpty ? null : email,
          department: _department,
          status: _status,
        ),
      ),
    );
  }

  static InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: AppTypography.label.copyWith(color: AppColors.textMuted),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 14,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.primaryLight, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StudentsBloc, StudentsState>(
      listenWhen: (previous, current) {
        String? feedback(StudentsState state) => state is StudentsLoaded
            ? state.addSuccess ?? state.addError
            : null;
        return feedback(previous) != feedback(current) &&
            feedback(current) != null;
      },
      listener: (context, state) {
        if (state is StudentsLoaded && state.addSuccess != null) {
          Navigator.of(context).pop();
        }
      },
      buildWhen: (previous, current) {
        bool? adding(StudentsState state) =>
            state is StudentsLoaded ? state.isAdding : null;
        String? error(StudentsState state) =>
            state is StudentsLoaded ? state.addError : null;
        return adding(previous) != adding(current) ||
            error(previous) != error(current);
      },
      builder: (context, state) {
        final isAdding = state is StudentsLoaded && state.isAdding;
        final addError = state is StudentsLoaded ? state.addError : null;
        final departments = state is StudentsLoaded
            ? state.kpis.availableDepartments
            : const <String>[];

        return AlertDialog(
          title: Text('Add New Student', style: AppTypography.sectionTitle),
          content: SizedBox(
            width: 460,
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Create a directory record. Required fields are '
                      'marked with *.',
                      style: AppTypography.caption,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TextFormField(
                      controller: _nameController,
                      textInputAction: TextInputAction.next,
                      decoration: _decoration('Full Name *'),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                          ? 'Name is required'
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _rollController,
                      textInputAction: TextInputAction.next,
                      decoration: _decoration(
                        'Roll Number *',
                      ).copyWith(hintText: 'e.g. CS2021-042'),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                          ? 'Roll number is required'
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _decoration('Email (optional)'),
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        if (email.isEmpty) return null;
                        final valid = RegExp(
                          r'^[\w.+-]+@[\w-]+\.[\w.-]+$',
                        ).hasMatch(email);
                        return valid ? null : 'Enter a valid email address';
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    DropdownButtonFormField<String?>(
                      initialValue: _department,
                      decoration: _decoration('Department'),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('No department'),
                        ),
                        for (final dept in departments)
                          DropdownMenuItem<String?>(
                            value: dept,
                            child: Text(dept),
                          ),
                      ],
                      onChanged: (value) =>
                          setState(() => _department = value),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    DropdownButtonFormField<String>(
                      initialValue: _status,
                      decoration: _decoration('Status'),
                      items: const [
                        DropdownMenuItem(value: 'active', child: Text('Active')),
                        DropdownMenuItem(
                          value: 'inactive',
                          child: Text('Inactive'),
                        ),
                      ],
                      onChanged: (value) => setState(
                        () => _status = value ?? 'active',
                      ),
                    ),
                    if (addError != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.dangerSurface,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 16,
                              color: AppColors.dangerDark,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                addError,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.dangerDark,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isAdding ? null : () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: isAdding ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.surface,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                textStyle: AppTypography.button,
              ),
              child: isAdding
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.surface,
                      ),
                    )
                  : const Text('Add Student'),
            ),
          ],
        );
      },
    );
  }
}
