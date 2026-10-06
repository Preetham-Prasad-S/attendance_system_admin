import 'package:attendance_system_admin/core/theme/app_colors.dart';
import 'package:attendance_system_admin/core/theme/app_radius.dart';
import 'package:attendance_system_admin/core/theme/app_spacing.dart';
import 'package:attendance_system_admin/core/theme/app_typography.dart';
import 'package:attendance_system_admin/features/institutes/domain/entities/institute_entity.dart';
import 'package:flutter/material.dart';

/// Row in the institutes registry table.
class InstitutesTableCard extends StatelessWidget {
  const InstitutesTableCard({
    super.key,
    required this.institutes,
    required this.selectedSlug,
    required this.onSelect,
    required this.onEdit,
    required this.onToggleActive,
  });

  final List<Institute> institutes;
  final String? selectedSlug;
  final ValueChanged<Institute> onSelect;
  final ValueChanged<Institute> onEdit;
  final ValueChanged<Institute> onToggleActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _TableHead(),
          for (final institute in institutes)
            _InstituteRow(
              institute: institute,
              isSelected: institute.slug == selectedSlug,
              onSelect: () => onSelect(institute),
              onEdit: () => onEdit(institute),
              onToggleActive: () => onToggleActive(institute),
            ),
          if (institutes.isEmpty)
            const Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Text(
                'No institutes yet. Create the first one to get started.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted),
              ),
            ),
        ],
      ),
    );
  }
}

class _TableHead extends StatelessWidget {
  const _TableHead();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.lg),
          topRight: Radius.circular(AppRadius.lg),
        ),
      ),
      child: const Row(
        children: [
          Expanded(child: _HeadCell('Institute')),
          SizedBox(width: AppSpacing.lg),
          Expanded(child: _HeadCell('Slug')),
          SizedBox(width: AppSpacing.lg),
          Expanded(child: _HeadCell('Status')),
          SizedBox(width: AppSpacing.sm),
        ],
      ),
    );
  }
}

class _HeadCell extends StatelessWidget {
  const _HeadCell(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: AppTypography.caption.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.textMuted,
      ),
    );
  }
}

class _InstituteRow extends StatelessWidget {
  const _InstituteRow({
    required this.institute,
    required this.isSelected,
    required this.onSelect,
    required this.onEdit,
    required this.onToggleActive,
  });

  final Institute institute;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: institute.isActive ? onSelect : null,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.border.withValues(alpha: 0.6),
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  if (isSelected) ...[
                    const Icon(
                      Icons.radio_button_checked,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          institute.name,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.label.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (institute.code != null)
                          Text(
                            institute.code!,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Text(
                institute.slug,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.label.copyWith(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Row(
                children: [
                  _StatusPill(isActive: institute.isActive),
                  const SizedBox(width: AppSpacing.sm),
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 17),
                    tooltip: 'Edit details',
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    onPressed: onToggleActive,
                    icon: Icon(
                      institute.isActive
                          ? Icons.pause_circle_outline
                          : Icons.play_circle_outline,
                      size: 17,
                    ),
                    tooltip: institute.isActive
                        ? 'Deactivate'
                        : 'Reactivate',
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 1,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: isActive ? AppColors.successSurface : AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: AppTypography.caption.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isActive ? AppColors.successDark : AppColors.textMuted,
        ),
      ),
    );
  }
}