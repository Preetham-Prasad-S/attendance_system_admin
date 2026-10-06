import 'package:attendance_system_admin/core/theme/app_colors.dart';
import 'package:attendance_system_admin/core/theme/app_radius.dart';
import 'package:attendance_system_admin/core/theme/app_spacing.dart';
import 'package:attendance_system_admin/core/theme/app_typography.dart';
import 'package:attendance_system_admin/features/institutes/domain/entities/institute_entity.dart';
import 'package:flutter/material.dart';

/// Sidebar control showing the institute whose data is on screen.
///
/// A super_admin gets a dropdown to switch between every institute. A regular
/// admin sees the same block as a locked label for their own institute: no
/// chevron, no tap target, nothing to get wrong.
class SidebarUniversitySelector extends StatelessWidget {
  const SidebarUniversitySelector({
    super.key,
    required this.institutes,
    required this.selected,
    required this.isSuperAdmin,
    required this.onChanged,
  });

  final List<Institute> institutes;
  final Institute? selected;
  final bool isSuperAdmin;
  final ValueChanged<Institute> onChanged;

  @override
  Widget build(BuildContext context) {
    final label = selected?.name ?? 'No institute selected';

    final card = Material(
      color: AppColors.surfaceMuted,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Campus Instance',
                    style: AppTypography.caption.copyWith(
                      fontSize: 10,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.label.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            if (isSuperAdmin)
              const Icon(
                Icons.unfold_more,
                size: 18,
                color: AppColors.textSecondary,
              )
            else
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );

    if (!isSuperAdmin) return card;

    return PopupMenuButton<Institute>(
      tooltip: 'Switch institute',
      onSelected: onChanged,
      position: PopupMenuPosition.under,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      itemBuilder: (context) => [
        for (final institute in institutes)
          PopupMenuItem<Institute>(
            value: institute,
            height: 44,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    institute.name,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.label.copyWith(
                      fontSize: 13,
                      fontWeight: institute.slug == selected?.slug
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: institute.slug == selected?.slug
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                if (institute.slug == selected?.slug)
                  const Icon(Icons.check, size: 16, color: AppColors.primary),
              ],
            ),
          ),
      ],
      child: card,
    );
  }
}
