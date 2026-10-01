import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../domain/entities/students_entities.dart';

/// Breadcrumb, page title, meta row (date + active-sessions chip) and the
/// header actions (Bulk Import stub / Export Directory / Add New Student).
class StudentsPageHeader extends StatelessWidget {
  const StudentsPageHeader({
    super.key,
    required this.kpis,
    required this.isExporting,
    required this.onExport,
    required this.onAddStudent,
  });

  final DirectoryKpis kpis;
  final bool isExporting;
  final VoidCallback onExport;
  final VoidCallback onAddStudent;

  @override
  Widget build(BuildContext context) {
    final departmentCount = kpis.availableDepartments.length;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Academics  /  Student Directory & Attendance Profiles',
                style: AppTypography.label.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Student Directory & Compliance',
                style: AppTypography.pageTitle,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Manage ${kpis.totalEnrolled} enrolled students across '
                '$departmentCount departments, monitor attendance thresholds '
                '(<75% risk), and inspect student records.',
                style: AppTypography.pageSubtitle,
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                runSpacing: AppSpacing.sm,
                spacing: AppSpacing.lg,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.schedule,
                        size: 14,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        DateFormat(
                          'EEEE, MMMM d, yyyy',
                        ).format(DateTime.now()),
                        style: AppTypography.label.copyWith(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.successSurface,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      'Academic Sessions Active',
                      style: AppTypography.caption.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.successDark,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.xl),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.upload_file_outlined, size: 16),
                  label: const Text('Bulk Import CSV/Excel'),
                  style: OutlinedButton.styleFrom(
                    disabledForegroundColor: AppColors.textMuted,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                OutlinedButton.icon(
                  onPressed: isExporting ? null : onExport,
                  icon: isExporting
                      ? const SizedBox(
                          width: 15,
                          height: 15,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.download_outlined, size: 17),
                  label: Text(isExporting ? 'Exporting…' : 'Export Directory'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              onPressed: onAddStudent,
              icon: const Icon(Icons.person_add_alt, size: 17),
              label: const Text('+ Add New Student'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.surface,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                textStyle: AppTypography.button,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
